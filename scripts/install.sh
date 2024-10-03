#!/bin/bash

# Install script for dynamic-memory-k8s project
# Run `build.sh` before running this script

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if necessary commands exist
if ! command_exists kubectl; then
    error "kubectl is not installed. Please install kubectl and try again."
fi

# Check if binaries exist
if [ ! -f "bin/scheduler-plugin" ] || [ ! -f "bin/dcd-controller" ] || [ ! -f "bin/kubectl-dynamic-memory" ]; then
    error "One or more binaries are missing. Please run ./scripts/build.sh first."
fi

echo "Installing dynamic-memory-k8s components..."

# Install scheduler plugin
echo "Installing scheduler plugin..."
kubectl apply -f deploy/scheduler-config.yaml || error "Failed to install scheduler plugin"

# Install DCD controller
echo "Installing DCD controller..."
kubectl apply -f deploy/dcd-controller.yaml || error "Failed to install DCD controller"

# Install kubectl plugin
echo "Installing kubectl dynamic-memory plugin..."
if [ -d "$HOME/.kube/plugins" ]; then
    mkdir -p "$HOME/.kube/plugins/dynamic-memory"
    cp bin/kubectl-dynamic-memory "$HOME/.kube/plugins/dynamic-memory/" || error "Failed to install kubectl plugin"
else
    sudo cp bin/kubectl-dynamic-memory /usr/local/bin/ || error "Failed to install kubectl plugin"
fi

echo -e "${GREEN}Installation completed successfully.${NC}"
echo "You can now use 'kubectl dynamic-memory' commands."
echo "To verify the installation, run:"
echo "  kubectl get pods -n kube-system | grep 'scheduler\|dcd-controller'"
echo "  kubectl dynamic-memory --help"