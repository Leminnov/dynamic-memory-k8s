package api

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// DynamicMemoryResource represents a dynamic memory resource
type DynamicMemoryResource struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   DynamicMemoryResourceSpec   `json:"spec"`
	Status DynamicMemoryResourceStatus `json:"status"`
}

// DynamicMemoryResourceSpec defines the desired state of DynamicMemoryResource
type DynamicMemoryResourceSpec struct {
	// Define fields for the desired state
	NodeName string `json:"nodeName"`
	Amount   int64  `json:"amount"`
}

// DynamicMemoryResourceStatus defines the observed state of DynamicMemoryResource
type DynamicMemoryResourceStatus struct {
	// Define fields for the observed state
	Available int64 `json:"available"`
	Used      int64 `json:"used"`
}

// Add other custom types as needed
