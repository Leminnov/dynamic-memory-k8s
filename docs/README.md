# Dynamic Memory Management in Kubernetes

This project implements dynamic or elastic memory capacity management in Kubernetes clusters using Compute Express Link (CXL) Dynamic Capacity Devices (DCD). It leverages Kubernetes extension mechanisms such as the Dynamic Resource Allocation (DRA) framework, custom scheduler plugins, and DaemonSets to enable on-demand memory provisioning without modifying core Kubernetes components.

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Requesting Dynamic Memory](#requesting-dynamic-memory)
  - [Viewing Dynamic Memory Allocations](#viewing-dynamic-memory-allocations)
- [Configuration](#configuration)
- [Monitoring and Metrics](#monitoring-and-metrics)
- [Contribution Guidelines](#contribution-guidelines)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Introduction

The advent of CXL Dynamic Capacity Devices allows for the dynamic addition and removal of memory at runtime without requiring system reboots or application restarts. This project integrates this capability into Kubernetes, enabling pods to request additional memory resources dynamically.

By utilizing Kubernetes' extensibility features, we introduce dynamic memory management in a way that is scalable, maintainable, and aligns with Kubernetes best practices.

---

## Features

- **Dynamic Memory Allocation**: Pods can request additional memory at runtime using `ResourceClaims`.
- **Dynamic Resource Allocation (DRA) Driver**: Implements the DRA framework to handle dynamic memory resources.
- **Custom Scheduler Plugin**: Enhances scheduling decisions based on dynamic memory capabilities.
- **Node Capacity Updater DaemonSet**: Updates node capacities to reflect dynamically allocated memory.
- **Kubectl Plugin**: Extends `kubectl` with commands to manage and inspect dynamic memory resources.
- **Metrics Exporter**: Provides monitoring of dynamic memory operations for observability.

---

## Architecture Overview

The project consists of several components that interact to facilitate dynamic memory allocation and management:

- **Dynamic Resource Allocation (DRA) Driver**
- **Scheduler Plugin**
- **Node Capacity Updater DaemonSet**
- **Dynamic Memory Service**
- **Custom Resource Definitions (CRDs)**
- **Kubectl Plugin**
- **Metrics Exporter**

For a detailed description of the architecture and component interactions, please refer to the [Architecture Documentation](architecture.md).

---

## Getting Started

### Prerequisites

- **Kubernetes Cluster**: Version 1.26 or higher (to support the DRA framework).
- **Go Programming Language**: Version 1.16 or higher.
- **Protocol Buffers Compiler (`protoc`)**: For generating gRPC code.
- **Docker**: For building container images.
- **Kubectl**: Kubernetes command-line tool.

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/dynamic-memory-k8s.git
cd dynamic-memory-k8s
```

#### 2. Build the Components

```bash
./scripts/build.sh
```

This script compiles the binaries for the DRA driver, scheduler plugin, node capacity updater, and dynamic memory service.

#### 3. Deploy to Kubernetes

```bash
./scripts/deploy.sh
```

This script applies the necessary Kubernetes manifests to deploy the components to your cluster.

#### 4. Verify the Deployment

Check that the pods are running:

```bash
kubectl get pods -n kube-system
```

---

## Usage

### Requesting Dynamic Memory

To request dynamic memory for a pod, create a `ResourceClaim` and reference it in your pod specification.

**Example ResourceClaim:**

```yaml
apiVersion: mygroup.example.com/v1
kind: DynamicMemoryResource
metadata:
  name: dynamic-memory-claim
spec:
  memoryMiB: 2048
```

**Example Pod Spec:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-memory-pod
spec:
  containers:
    - name: app
      image: yourapplication:latest
      resources:
        requests:
          memory: "512Mi"
      volumeMounts:
        - name: dynamic-memory
          mountPath: /mnt/dynamic-memory
  resourceClaims:
    - name: dynamic-memory-claim
```

Apply the manifests:

```bash
kubectl apply -f examples/resource-claims/dynamic-memory-claim.yaml
kubectl apply -f examples/pods/dynamic-memory-pod.yaml
```

### Viewing Dynamic Memory Allocations

Use the `kubectl` plugin to view dynamic memory allocations:

```bash
kubectl dynamic-memory get claims
```

---

## Configuration

Configuration files for each component are located in the `configs/` directory. Key configurations include:

- **DRA Driver**: `configs/dra-driver-config.yaml`
- **Scheduler Plugin**: `configs/scheduler-config.yaml`
- **Node Capacity Updater**: `configs/updater-config.yaml`

Adjust the configurations as needed before deploying the components.

---

## Monitoring and Metrics

The metrics exporter exposes Prometheus metrics at `http://<metrics-exporter-service>:2112/metrics`.

Key metrics include:

- `dynamic_memory_allocations_total`: Total number of dynamic memory allocations.
- `dynamic_memory_allocation_errors_total`: Total number of allocation errors.
- `dynamic_memory_current_usage_bytes`: Current dynamic memory usage per node.

To visualize these metrics, set up Prometheus and Grafana dashboards.

---

## Contribution Guidelines

We welcome contributions from the community! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Write your code and tests.
4. Submit a pull request with a detailed description of your changes.

Please refer to the [Developer Guide](developer-guide.md) for more information on setting up your development environment and our coding standards.