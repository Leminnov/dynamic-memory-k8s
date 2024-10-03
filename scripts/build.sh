#!/bin/bash

# Build script for dynamic-memory-k8s project

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

# Check if Go is installed
if ! command -v go &> /dev/null; then
    error "Go is not installed. Please install Go and try again."
fi

echo "Building dynamic-memory-k8s project..."

# Create bin directory if it doesn't exist
mkdir -p bin

# Build scheduler plugin
echo "Building scheduler plugin..."
go build -o bin/scheduler-plugin cmd/scheduler-plugin/main.go || error "Failed to build scheduler plugin"

# Build DCD controller
echo "Building DCD controller..."
go build -o bin/dcd-controller cmd/dcd-controller/main.go || error "Failed to build DCD controller"

# Build kubectl-dynamic-memory plugin
echo "Building kubectl-dynamic-memory plugin..."
go build -o bin/kubectl-dynamic-memory cmd/kubectl-dynamic-memory/main.go || error "Failed to build kubectl-dynamic-memory plugin"

echo -e "${GREEN}Build completed successfully.${NC}"
echo "Binaries are available in the 'bin' directory:"
echo "- bin/scheduler-plugin"
echo "- bin/dcd-controller"
echo "- bin/kubectl-dynamic-memory"