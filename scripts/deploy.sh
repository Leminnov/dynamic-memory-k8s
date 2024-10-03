#!/bin/bash

# Deploy script for dynamic-memory-k8s project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    error "kubectl is not installed. Please install kubectl and try again."
fi

# Check if we're using Minikube or a regular Kubernetes cluster
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    MINIKUBE=true
    echo "Detected Minikube environment"
else
    MINIKUBE=false
    echo "Using regular Kubernetes cluster"
fi

# Build Docker images
echo "Building Docker images..."
docker build -f Dockerfile.scheduler-plugin -t scheduler-plugin:latest . || error "Failed to build scheduler-plugin image"
docker build -f Dockerfile.dcd-controller -t dcd-controller:latest . || error "Failed to build dcd-controller image"

# Load images into Minikube if using Minikube
if [ "$MINIKUBE" = true ]; then
    echo "Loading images into Minikube..."
    minikube image load scheduler-plugin:latest || error "Failed to load scheduler-plugin image into Minikube"
    minikube image load dcd-controller:latest || error "Failed to load dcd-controller image into Minikube"
fi

# Apply RBAC configuration
echo "Applying RBAC configuration..."
kubectl apply -f deploy/rbac.yaml || error "Failed to apply RBAC configuration"

# Deploy scheduler plugin
echo "Deploying scheduler plugin..."
kubectl apply -f deploy/scheduler-config.yaml || error "Failed to deploy scheduler plugin"

# Deploy DCD controller
echo "Deploying DCD controller..."
kubectl apply -f deploy/dcd-controller.yaml || error "Failed to deploy DCD controller"

echo -e "${GREEN}Deployment completed successfully.${NC}"