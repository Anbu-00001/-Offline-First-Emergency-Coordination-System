package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all cross-origin connections for local testing
	},
}

// APIServer handles HTTP requests and WebSocket connections
type APIServer struct {
	port          int
	pubSubManager *PubSubManager
	msgChan       chan NetworkEnvelope
	clients       map[*websocket.Conn]bool
	clientsMux    sync.RWMutex
}

// NewAPIServer creates a new API Server instance
func NewAPIServer(port int, psm *PubSubManager, msgChan chan NetworkEnvelope) *APIServer {
	return &APIServer{
		port:          port,
		pubSubManager: psm,
		msgChan:       msgChan,
		clients:       make(map[*websocket.Conn]bool),
	}
}

// Start boots the HTTP server in a goroutine
func (s *APIServer) Start() error {
	mux := http.NewServeMux()

	// Setup routes
	mux.HandleFunc("/broadcast", s.handleBroadcast)
	mux.HandleFunc("/events", s.handleEvents)

	go s.broadcastLoop() // Loop to read from msgChan and send to all WS clients

	serverAddr := fmt.Sprintf(":%d", s.port)
	log.Printf("[API] Starting P2P API Server at HTTP/WS %s", serverAddr)

	go func() {
		if err := http.ListenAndServe(serverAddr, mux); err != nil {
			log.Fatalf("[API] Server failed: %v", err)
		}
	}()

	return nil
}

// handleBroadcast is the HTTP handler for POST /broadcast
// Accepts a NetworkEnvelope JSON body and publishes it via GossipSub.
func (s *APIServer) handleBroadcast(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var envelope NetworkEnvelope
	if err := json.NewDecoder(r.Body).Decode(&envelope); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Publish via GossipSub (Broadcast fills in msg_id, origin_peer, timestamp if missing)
	if err := s.pubSubManager.Broadcast(envelope); err != nil {
		log.Printf("[API] Failed to broadcast message: %v\n", err)
		http.Error(w, "Failed to broadcast", http.StatusInternalServerError)
		return
	}

	log.Printf("[API] POST /broadcast processed: msg_id=%s msg_type=%s", envelope.MsgID, envelope.MsgType)

	w.WriteHeader(http.StatusAccepted)
	json.NewEncoder(w).Encode(map[string]string{"status": "broadcasted"})
}

// handleEvents upgrades the GET request to a WebSocket connection
func (s *APIServer) handleEvents(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[API] Failed to upgrade WebSocket: %v", err)
		return
	}

	// Register the new client
	s.clientsMux.Lock()
	s.clients[conn] = true
	s.clientsMux.Unlock()

	log.Printf("[API] WebSocket client connected: %s", conn.RemoteAddr().String())

	// Read loop just to handle disconnects
	go func() {
		defer func() {
			s.clientsMux.Lock()
			delete(s.clients, conn)
			s.clientsMux.Unlock()
			conn.Close()
			log.Printf("[API] WebSocket client disconnected: %s", conn.RemoteAddr().String())
		}()
		for {
			if _, _, err := conn.ReadMessage(); err != nil {
				break
			}
		}
	}()
}

// broadcastLoop reads from the p2p input channel and forwards NetworkEnvelopes to all connected WebSockets
func (s *APIServer) broadcastLoop() {
	for envelope := range s.msgChan {
		// Serialize envelope
		data, err := json.Marshal(envelope)
		if err != nil {
			log.Printf("[API] Failed to marshal WS broadcast envelope: %v", err)
			continue
		}

		s.clientsMux.RLock()
		for client := range s.clients {
			if err := client.WriteMessage(websocket.TextMessage, data); err != nil {
				log.Printf("[API] Failed to send message to WS client: %v", err)
				client.Close()
			}
		}
		s.clientsMux.RUnlock()
	}
}
