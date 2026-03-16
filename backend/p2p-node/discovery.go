package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/libp2p/go-libp2p/core/host"
	"github.com/libp2p/go-libp2p/core/peer"
	"github.com/libp2p/go-libp2p/p2p/discovery/mdns"
)

const discoveryServiceTag = "openrescue.p2p"

// discoveryNotifee gets notified when we find a new peer via mDNS discovery
type discoveryNotifee struct {
	h host.Host
}

// HandlePeerFound connects to peers discovered via mDNS
func (n *discoveryNotifee) HandlePeerFound(pi peer.AddrInfo) {
	// Don't try to connect to ourselves
	if pi.ID == n.h.ID() {
		return
	}

	log.Printf("[Discovery] Peer discovered via mDNS: %s", pi.ID)

	// Connect to the peer
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	err := n.h.Connect(ctx, pi)
	if err != nil {
		log.Printf("[Discovery] Failed to connect to peer %s: %s", pi.ID.String(), err)
	} else {
		log.Printf("[Discovery] Peer connected: %s (addrs: %v)", pi.ID.String(), pi.Addrs)
	}
}

// setupDiscovery creates an mDNS discovery service
func setupDiscovery(h host.Host) error {
	s := mdns.NewMdnsService(h, discoveryServiceTag, &discoveryNotifee{h: h})
	if s == nil {
		return fmt.Errorf("failed creating mDNS service")
	}

	if err := s.Start(); err != nil {
		return fmt.Errorf("failed starting mDNS service: %v", err)
	}

	log.Printf("[Discovery] mDNS Peer Discovery started (service tag: %s)\n", discoveryServiceTag)
	return nil
}
