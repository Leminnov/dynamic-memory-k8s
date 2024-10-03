# Installation Guide

This guide will help you set up the dynamic memory Kubernetes extension for development and testing purposes.

## Prerequisites

- Go 1.21 or later
- Docker
- Minikube or a Kubernetes cluster
- kubectl

## Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/sscargal/dynamic-memory-k8s.git
   cd dynamic-memory-k8s
   ```

2. Make the shell scripts executable:
   ```
   cd scripts
   chmod +x build.sh deploy.sh test.sh update-deps.sh
   ```

## Building the Project

To build the project, simply run:

```
./build.sh
```

This script will build both the scheduler plugin and the DCD controller.

## Updating Dependencies

To update the Go module dependencies, run:

```
./update-deps.sh
```

This script will update all dependencies, tidy the go.mod file, and optionally run tests after updating.

## Running Tests

To run all tests for the project, use:

```
./test.sh
```

This script will execute unit tests, integration tests, and end-to-end tests (if available).

## Deploying on Minikube or Kubernetes

To deploy the project on Minikube or a Kubernetes cluster, use:

```
./deploy.sh
```

This script will:
- Build Docker images for the scheduler plugin and DCD controller
- Load images into Minikube (if using Minikube)
- Apply RBAC configuration
- Deploy the scheduler plugin and DCD controller

## Verifying the Installation

1. Check that the scheduler plugin and DCD controller pods are running:
   ```
   kubectl get pods -n kube-system
   ```

2. You should see pods for the scheduler plugin and DCD controller in the Running state.

## Testing the Deployment

1. Apply a sample pod configuration that uses dynamic memory:
   ```
   kubectl apply -f examples/pod-with-dynamic-memory.yaml
   ```

2. Verify that the pod is scheduled and running:
   ```
   kubectl get pods
   ```

3. Check the logs of the scheduler plugin and DCD controller for any issues:
   ```
   kubectl logs -n kube-system <scheduler-plugin-pod-name>
   kubectl logs -n kube-system <dcd-controller-pod-name>
   ```

## Troubleshooting

- If you encounter any issues with dependencies, try running `./update-deps.sh` again.
- Ensure that your Kubernetes cluster has the necessary features enabled for dynamic memory allocation.
- Check the logs of the scheduler plugin and DCD controller for any error messages or warnings.

For more detailed information on usage and configuration, please refer to the project's README and other documentation in the `docs/` directory.
