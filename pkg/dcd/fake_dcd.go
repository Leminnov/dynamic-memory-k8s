package dcd

import (
	"errors"
	"sync"
)

var ErrInsufficientMemory = errors.New("insufficient memory")

// FakeDCDService simulates a DCD service for testing and early development
type FakeDCDService struct {
	mu         sync.Mutex
	nodeMemory map[string]int64
}

// NewFakeDCDService creates a new FakeDCDService
func NewFakeDCDService() *FakeDCDService {
	return &FakeDCDService{
		nodeMemory: make(map[string]int64),
	}
}

// AddMemory simulates adding memory to a node
func (f *FakeDCDService) AddMemory(nodeID string, amount int64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.nodeMemory[nodeID] += amount
	return nil
}

// RemoveMemory simulates removing memory from a node
func (f *FakeDCDService) RemoveMemory(nodeID string, amount int64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.nodeMemory[nodeID] < amount {
		return ErrInsufficientMemory
	}
	f.nodeMemory[nodeID] -= amount
	return nil
}

// GetAvailableMemory returns the simulated available memory for a node
func (f *FakeDCDService) GetAvailableMemory(nodeID string) (int64, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.nodeMemory[nodeID], nil
}
