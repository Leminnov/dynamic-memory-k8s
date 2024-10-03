# Testing Guide

This document provides instructions for setting up a test environment and running the project's unit and integration tests using a local Kubernetes cluster created with [Kind](https://kind.sigs.k8s.io/) or [Minikube](https://minikube.sigs.k8s.io/).

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setting Up a Test Cluster](#setting-up-a-test-cluster)
   - [Using Kind](#using-kind)
   - [Using Minikube](#using-minikube)
3. [Running the Tests](#running-the-tests)
   - [Unit Tests](#unit-tests)
   - [Integration Tests](#integration-tests)
4. [Troubleshooting](#troubleshooting)
5. [Cleaning Up](#cleaning-up)
6. [Additional Resources](#additional-resources)

---

## Prerequisites

Before running the tests, ensure that you have the following installed on your machine:

- **Go**: Version 1.18 or later
- **Docker**: Required for running Kind or Minikube with the Docker driver
- **kubectl**: Kubernetes command-line tool
- **Kind**: For running a local Kubernetes cluster in Docker (optional)
- **Minikube**: For running a local Kubernetes cluster (optional)
- **Make**: For running build and test scripts (optional)

---

## Setting Up a Test Cluster

You can use either Kind or Minikube to create a local Kubernetes cluster for testing. Choose the one that best fits your environment.

### Using Kind

[Kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) is a tool for running local Kubernetes clusters using Docker container "nodes".

#### Install Kind

```bash
GO111MODULE="on" go install sigs.k8s.io/kind@v0.17.0
```

Ensure that `kind` is in your `PATH`:

```bash
export PATH="$(go env GOPATH)/bin:$PATH"
```

#### Create a Cluster

```bash
kind create cluster --name dynamic-memory-test
```

This command will create a Kubernetes cluster named `dynamic-memory-test`.

#### Verify the Cluster

```bash
kubectl cluster-info --context kind-dynamic-memory-test
```

Set the `KUBECONFIG` environment variable:

```bash
export KUBECONFIG="$(kind get kubeconfig-path --name="dynamic-memory-test")"
```

### Using Minikube

[Minikube](https://minikube.sigs.k8s.io/) runs a single-node Kubernetes cluster on your local machine.

#### Install Minikube

Follow the installation guide for your operating system: [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/).

#### Start Minikube

```bash
minikube start
```

#### Verify the Cluster

```bash
kubectl cluster-info
```

Minikube automatically configures `kubectl` to use the cluster. You can check the current context:

```bash
kubectl config current-context
```

---

## Running the Tests

Once your test cluster is up and running, you can proceed to run the project's tests.

### Unit Tests

Unit tests do not require a running Kubernetes cluster.

#### Run Unit Tests

From the root directory of the project, execute:

```bash
./scripts/test.sh
```

This script will run both unit and integration tests. To run only the unit tests:

```bash
go test ./test/unit/... -v
```

### Integration Tests

Integration tests require a running Kubernetes cluster and the `KUBECONFIG` environment variable to be set.

#### Ensure `KUBECONFIG` is Set

Check that `KUBECONFIG` points to your cluster's kubeconfig file:

```bash
echo $KUBECONFIG
```

If not set, you can set it manually:

- **Kind**:

  ```bash
  export KUBECONFIG="$(kind get kubeconfig-path --name="dynamic-memory-test")"
  ```

- **Minikube**:

  ```bash
  export KUBECONFIG="$HOME/.kube/config"
  ```

#### Run Integration Tests

Run the test script:

```bash
./scripts/test.sh
```

This will run both unit and integration tests. The script checks for `KUBECONFIG` and runs integration tests accordingly.

Alternatively, to run only the integration tests:

```bash
go test ./test/integration/... -v
```

---

## Troubleshooting

- **Cluster Connection Issues**: If the tests fail to connect to the cluster, verify that the cluster is running and that `kubectl` can connect to it.

  ```bash
  kubectl get nodes
  ```

- **Permissions Errors**: Ensure that you have the necessary permissions to create resources in the cluster. For local clusters, the default user typically has admin privileges.

- **Environment Variables**: Double-check that `KUBECONFIG` is set correctly.

- **Docker Daemon**: If using Kind, ensure that the Docker daemon is running.

- **Port Conflicts**: The custom scheduler may conflict with the default scheduler. Ensure that only one scheduler is running, or use different ports.

---

## Cleaning Up

After running the tests, you can delete the test cluster to free up resources.

### Delete Kind Cluster

```bash
kind delete cluster --name dynamic-memory-test
```

### Stop Minikube

```bash
minikube stop
```

To delete the Minikube cluster:

```bash
minikube delete
```

---

## Additional Resources

- **Kind Documentation**: [https://kind.sigs.k8s.io/docs/user/quick-start/](https://kind.sigs.k8s.io/docs/user/quick-start/)
- **Minikube Documentation**: [https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)
- **Kubernetes Testing Guide**: [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)