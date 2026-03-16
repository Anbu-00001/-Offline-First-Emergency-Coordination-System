package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/google/uuid"
	pubsub "github.com/libp2p/go-libp2p-pubsub"
	"github.com/libp2p/go-libp2p/core/host"
)

const IncidentTopic = "openrescue.incident"
const dedupCacheSize = 1000

// NetworkEnvelope is the standardized message envelope for P2P communication.
// Designed to be forward-compatible: unknown fields in Payload are preserved.
type NetworkEnvelope struct {
	MsgID      string                 `json:"msg_id"`
	MsgType    string                 `json:"msg_type"`
	OriginPeer string                 `json:"origin_peer"`
	Timestamp  int64                  `json:"timestamp"`
	Payload    map[string]interface{} `json:"payload"`
}

// dedupCache provides O(1) duplicate detection with bounded memory using a ring buffer.
type dedupCache struct {
	mu    sync.RWMutex
	seen  map[string]bool
	ring  []string
	index int
	size  int
}

func newDedupCache(size int) *dedupCache {
	return &dedupCache{
		seen: make(map[string]bool, size),
		ring: make([]string, size),
		size: size,
	}
}

// isDuplicate returns true if msgID was already seen; otherwise adds it.
func (c *dedupCache) isDuplicate(msgID string) bool {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.seen[msgID] {
		return true
	}

	// Evict oldest entry if ring is full
	if old := c.ring[c.index]; old != "" {
		delete(c.seen, old)
	}

	c.ring[c.index] = msgID
	c.seen[msgID] = true
	c.index = (c.index + 1) % c.size
	return false
}

type PubSubManager struct {
	ctx     context.Context
	ps      *pubsub.PubSub
	topic   *pubsub.Topic
	sub     *pubsub.Subscription
	host    host.Host
	msgChan chan NetworkEnvelope
	dedup   *dedupCache
}

// setupPubSub initializes GossipSub and subscribes to the incident topic
func setupPubSub(ctx context.Context, h host.Host, msgChan chan NetworkEnvelope) (*PubSubManager, error) {
	// Create a new GossipSub routing instance
	ps, err := pubsub.NewGossipSub(ctx, h)
	if err != nil {
		return nil, fmt.Errorf("failed to create GossipSub: %w", err)
	}

	// Join the topic
	topic, err := ps.Join(IncidentTopic)
	if err != nil {
		return nil, fmt.Errorf("failed to join topic: %w", err)
	}

	// Subscribe to the topic
	sub, err := topic.Subscribe()
	if err != nil {
		return nil, fmt.Errorf("failed to subscribe to topic: %w", err)
	}

	manager := &PubSubManager{
		ctx:     ctx,
		ps:      ps,
		topic:   topic,
		sub:     sub,
		host:    h,
		msgChan: msgChan,
		dedup:   newDedupCache(dedupCacheSize),
	}

	// Start listening for messages in the background
	go manager.listenLoop()

	log.Printf("Joined GossipSub topic: %s", IncidentTopic)
	return manager, nil
}

// listenLoop continuously reads from the subscription
func (m *PubSubManager) listenLoop() {
	for {
		msg, err := m.sub.Next(m.ctx)
		if err != nil {
			log.Printf("[PubSub] Error reading from GossipSub: %s\n", err)
			return
		}

		// Don't process our own messages internally
		if msg.ReceivedFrom == m.host.ID() {
			continue
		}

		// Parse the JSON envelope
		var envelope NetworkEnvelope
		if err := json.Unmarshal(msg.Data, &envelope); err != nil {
			log.Printf("[PubSub] Failed to unmarshal GossipSub message: %s\n", err)
			continue
		}

		// Deduplication check
		if m.dedup.isDuplicate(envelope.MsgID) {
			log.Printf("[PubSub] Duplicate message ignored: msg_id=%s from peer %s\n", envelope.MsgID, msg.ReceivedFrom)
			continue
		}

		log.Printf("[PubSub] Message received: msg_id=%s msg_type=%s from peer %s\n", envelope.MsgID, envelope.MsgType, msg.ReceivedFrom)

		// Forward to the channel for the WebSocket API to pick up
		select {
		case m.msgChan <- envelope:
		default:
			log.Println("[PubSub] Message channel full, dropping message")
		}
	}
}

// Broadcast serializes and publishes a network envelope
func (m *PubSubManager) Broadcast(envelope NetworkEnvelope) error {
	// Stamp origin_peer with our peer ID
	envelope.OriginPeer = m.host.ID().String()

	// Generate msg_id if not provided
	if envelope.MsgID == "" {
		envelope.MsgID = uuid.New().String()
	}

	// Set timestamp if not provided
	if envelope.Timestamp == 0 {
		envelope.Timestamp = time.Now().Unix()
	}

	// Default msg_type
	if envelope.MsgType == "" {
		envelope.MsgType = "incident_create"
	}

	// Add to our own dedup cache to prevent echo
	m.dedup.isDuplicate(envelope.MsgID)

	data, err := json.Marshal(envelope)
	if err != nil {
		return fmt.Errorf("failed to marshal envelope: %w", err)
	}

	log.Printf("[PubSub] Message published: msg_id=%s msg_type=%s\n", envelope.MsgID, envelope.MsgType)
	return m.topic.Publish(m.ctx, data)
}
