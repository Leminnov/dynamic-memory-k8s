package dcd

// DCDService defines the interface for interacting with Dynamic Capacity Devices
type DCDService interface {
	AddMemory(nodeID string, amount int64) error
	RemoveMemory(nodeID string, amount int64) error
	GetAvailableMemory(nodeID string) (int64, error)
}

// Implement the actual DCDService when hardware support is available
