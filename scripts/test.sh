#!/bin/bash

# Test script for dynamic-memory-k8s project

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

echo "Running tests for dynamic-memory-k8s project..."

# Run unit tests
echo "Running unit tests..."
go test ./... -v || error "Unit tests failed"

# Run integration tests (if any)
echo "Running integration tests..."
# Add your integration test command here, for example:
# go test ./test/integration/... -v || error "Integration tests failed"

# Run end-to-end tests (if any)
echo "Running end-to-end tests..."
# Add your e2e test command here, for example:
# go test ./test/e2e/... -v || error "End-to-end tests failed"

echo -e "${GREEN}All tests passed successfully.${NC}"