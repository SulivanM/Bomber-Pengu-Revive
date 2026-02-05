package main

import (
	"log"
	"sync"
	"time"
)

// ConnWriter is an interface for connections that can write data
type ConnWriter interface {
	Write([]byte) (int, error)
}

type Player struct {
	Name     string
	Conn     ConnWriter
	State    int
	Skill    int
	Hash     string
	LastBeat time.Time
	InGame   bool
	Opponent *Player
	mu       sync.Mutex
}

func (p *Player) Send(message string) {
	p.mu.Lock()
	defer p.mu.Unlock()

	if p.Conn != nil {
		_, err := p.Conn.Write([]byte(message + "\n"))
		if err != nil {
			log.Printf("Error sending to %s: %v", p.Name, err)
		}
	}
}
