# User Guide: Dynamic Memory Allocation in Kubernetes

This user guide provides step-by-step instructions for deploying and using the dynamic memory allocation system in Kubernetes clusters. It covers installation, configuration, and usage examples to help you get started with dynamic or elastic memory capacities using Compute Express Link (CXL) Dynamic Capacity Devices (DCD).

---

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
   - [1. Clone the Repository](#1-clone-the-repository)
   - [2. Build the Components](#2-build-the-components)
   - [3. Deploy the CRDs](#3-deploy-the-crds)
   - [4. Deploy the Dynamic Memory Service](#4-deploy-the-dynamic-memory-service)
   - [5. Deploy the DRA Driver](#5-deploy-the-dra-driver)
   - [6. Deploy the Scheduler Plugin](#6-deploy-the-scheduler-plugin)
   - [7. Deploy the Node Capacity Updater](#7-deploy-the-node-capacity-updater)
4. [Usage](#usage)
   - [1. Creating a ResourceClass](#1-creating-a-resourceclass)
   - [2. Creating a ResourceClaim](#2-creating-a-resourceclaim)
   - [3. Pod Specification](#3-pod-specification)
   - [4. Using the Kubectl Plugin](#4-using-the-kubectl-plugin)
5. [Monitoring and Metrics](#monitoring-and-metrics)
6. [Troubleshooting](#troubleshooting)
7. [Uninstallation](#uninstallation)
8. [Frequently Asked Questions](#frequently-asked-questions)
9. [Support and Contributions](#support-and-contributions)

---

## Introduction

This guide helps you integrate dynamic memory allocation into your Kubernetes cluster. With this system, you can:

- Dynamically allocate memory to pods at runtime.
- Schedule pods based on both static and dynamically allocatable memory.
- Monitor dynamic memory usage across your cluster.

By following this guide, you'll be able to deploy the necessary components and start using dynamic memory in your Kubernetes workloads.

---

## Prerequisites

Before you begin, ensure you have the following:

- A Kubernetes cluster running version **1.26** or later.
- **kubectl** configured to interact with your cluster.
- **Helm** (optional, for deploying using Helm charts).
- Sufficient permissions to deploy Custom Resource Definitions (CRDs) and cluster-wide resources.
- Go language environment (for building components).

---

## Installation

### 1. Clone the Repository

Clone the project repository to your local machine:

```bash
git clone https://github.com/yourusername/dynamic-memory-k8s.git
cd dynamic-memory-k8s
```

### 2. Build the Components

Build the necessary binaries using the provided script:

```bash
./scripts/build.sh
```

This script compiles the following components:

- Dynamic Resource Allocation (DRA) Driver
- Scheduler Plugin
- Node Capacity Updater
- Dynamic Memory Service (for testing purposes)

Ensure that the binaries are available in the `bin/` directory.

### 3. Deploy the CRDs

Apply the Custom Resource Definitions (CRDs) to your cluster:

```bash
kubectl apply -f api/crds/dynamicmemory.crd.yaml
```

### 4. Deploy the Dynamic Memory Service

For testing, deploy the simulated dynamic memory service:

```bash
kubectl apply -f deployments/dynamic-memory-service.yaml
```

Verify that the service is running:

```bash
kubectl get pods
```

### 5. Deploy the DRA Driver

Deploy the DRA driver, which handles dynamic memory allocation requests:

```bash
kubectl apply -f deployments/dra-driver.yaml
```

### 6. Deploy the Scheduler Plugin

Deploy the custom scheduler plugin:

```bash
kubectl apply -f deployments/scheduler-plugin.yaml
```

**Note**: Depending on your Kubernetes setup, you may need to modify the scheduler deployment to include the plugin. Refer to your distribution's documentation for customizing the scheduler.

### 7. Deploy the Node Capacity Updater

Deploy the Node Capacity Updater DaemonSet:

```bash
kubectl apply -f deployments/node-capacity-updater.yaml
```

This DaemonSet runs on each node to update the memory capacity based on dynamic allocations.

---

## Usage

### 1. Creating a ResourceClass

A `ResourceClass` defines the parameters for dynamic memory allocation. Create a `ResourceClass` named `dynamic-memory-class`:

```yaml
apiVersion: resource.k8s.io/v1alpha2
kind: ResourceClass
metadata:
  name: dynamic-memory-class
parameters:
  driverName: dynamicmemory.example.com
```

Apply the `ResourceClass`:

```bash
kubectl apply -f examples/resource-classes/dynamic-memory-class.yaml
```

### 2. Creating a ResourceClaim

A `ResourceClaim` represents a request for dynamic memory. Create a `ResourceClaim` requesting 2048 MiB of memory:

```yaml
apiVersion: resource.k8s.io/v1alpha2
kind: ResourceClaim
metadata:
  name: my-dynamic-memory-claim
spec:
  resourceClassName: dynamic-memory-class
  parameters:
    memoryMiB: 2048
```

Apply the `ResourceClaim`:

```bash
kubectl apply -f examples/resource-claims/my-dynamic-memory-claim.yaml
```

### 3. Pod Specification

Modify your pod specification to use the `ResourceClaim`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-memory-pod
spec:
  containers:
    - name: my-app
      image: alpine
      command: ["sleep", "3600"]
      resources:
        claims:
          - name: my-dynamic-memory-claim
```

Apply the pod manifest:

```bash
kubectl apply -f examples/pods/dynamic-memory-pod.yaml
```

### 4. Using the Kubectl Plugin

The `kubectl` plugin provides commands to manage dynamic memory resources.

#### 4.1. Install the Plugin

Copy the plugin binary to your `kubectl` plugins directory:

```bash
cp bin/kubectl-dynamic-memory ~/.kube/plugins/kubectl-dynamic-memory
chmod +x ~/.kube/plugins/kubectl-dynamic-memory
```

#### 4.2. List ResourceClaims

List all dynamic memory `ResourceClaims`:

```bash
kubectl dynamic-memory get claims
```

#### 4.3. Describe a ResourceClaim

Get detailed information about a specific `ResourceClaim`:

```bash
kubectl dynamic-memory describe claim my-dynamic-memory-claim
```

---

## Monitoring and Metrics

The system exposes metrics for monitoring dynamic memory usage.

### 1. Access Metrics

The metrics exporter runs on port `2112`. To access the metrics:

```bash
kubectl port-forward svc/metrics-exporter 2112:2112
```

Visit [http://localhost:2112/metrics](http://localhost:2112/metrics) to view the metrics.

### 2. Prometheus Integration

If you're using Prometheus, add the following scrape configuration:

```yaml
- job_name: 'dynamic-memory'
  static_configs:
    - targets: ['<metrics_exporter_service>:2112']
```

Replace `<metrics_exporter_service>` with the service name or IP address of the metrics exporter.

---

## Troubleshooting

### 1. Pod Pending Due to Unschedulable Nodes

**Issue**: The pod remains in a `Pending` state.

**Solution**:

- Check if the `ResourceClaim` has been allocated:

  ```bash
  kubectl get resourceclaim my-dynamic-memory-claim -o yaml
  ```

- Ensure that the scheduler plugin is correctly deployed and active.

- Verify that the Node Capacity Updater is running on all nodes:

  ```bash
  kubectl get daemonset node-capacity-updater
  ```

### 2. Memory Allocation Fails

**Issue**: Dynamic memory allocation fails during pod scheduling.

**Solution**:

- Check the logs of the DRA driver:

  ```bash
  kubectl logs deployment/dra-driver
  ```

- Check the logs of the dynamic memory service:

  ```bash
  kubectl logs deployment/dynamic-memory-service
  ```

- Ensure that the dynamic memory service is reachable from the DRA driver.

### 3. Metrics Not Available

**Issue**: Unable to access metrics at `http://localhost:2112/metrics`.

**Solution**:

- Verify that the metrics exporter is running:

  ```bash
  kubectl get pods -l app=metrics-exporter
  ```

- Check for network policies or firewalls blocking access.

---

## Uninstallation

To remove all components from your cluster, run:

```bash
kubectl delete -f deployments/
kubectl delete -f api/crds/dynamicmemory.crd.yaml
kubectl delete resourceclaim my-dynamic-memory-claim
kubectl delete resourceclass dynamic-memory-class
kubectl delete pod dynamic-memory-pod
```

---

## Frequently Asked Questions

### 1. **Which Kubernetes versions are supported?**

The system requires Kubernetes version **1.26** or later due to the use of the Dynamic Resource Allocation (DRA) framework.

### 2. **Can I use this in a production environment?**

As the DRA feature is in alpha, it's recommended to use this system in testing or development environments. Check the Kubernetes documentation for the current status of the DRA feature.

### 3. **How does this affect existing workloads?**

The system is designed to be non-intrusive. Existing workloads not requesting dynamic memory will operate as usual.

### 4. **Is the dynamic memory service secure?**

Ensure that communications between components are secured using TLS and proper authentication mechanisms. Update configurations to use secure connections.

---

## Support and Contributions

### 1. **Getting Help**

If you encounter issues or have questions:

- Open an issue on the [GitHub repository](https://github.com/yourusername/dynamic-memory-k8s/issues).
- Reach out to the maintainers via the contact information provided in the repository.

### 2. **Contributing**

Contributions are welcome! To contribute:

- Fork the repository.
- Create a new branch for your feature or bugfix.
- Submit a pull request with a detailed description of your changes.

Please read the `CONTRIBUTING.md` file for more information.