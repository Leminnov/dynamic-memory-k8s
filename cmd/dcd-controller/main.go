package main

import (
	"flag"

	"k8s.io/client-go/rest"
	"k8s.io/klog/v2"

	// These are placeholder imports. You'll need to create these packages.
	"github.com/sscargal/dynamic-memory-k8s/pkg/dra"
)

func main() {
	klog.InitFlags(nil)
	flag.Parse()

	config, err := rest.InClusterConfig()
	if err != nil {
		klog.Fatalf("Failed to get in-cluster config: %v", err)
	}

	controller, err := dra.NewDynamicMemoryController(config)
	if err != nil {
		klog.Fatalf("Failed to create dynamic memory controller: %v", err)
	}

	stopCh := make(chan struct{})
	if err := controller.Run(stopCh); err != nil {
		klog.Fatalf("Error running controller: %v", err)
	}
}
