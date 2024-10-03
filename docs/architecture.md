# Architecture Documentation

This document provides a detailed overview of the architecture for implementing dynamic or elastic memory capacities in Kubernetes using Compute Express Link (CXL) Dynamic Capacity Devices (DCD). The architecture leverages Kubernetes extension mechanisms, including the Dynamic Resource Allocation (DRA) framework, custom scheduler plugins, and DaemonSets, to enable dynamic memory provisioning without modifying core Kubernetes components.

---

## Table of Contents

1. [Introduction](#introduction)
2. [High-Level Architecture](#high-level-architecture)
3. [Components](#components)
   - [1. Dynamic Resource Allocation (DRA) Driver](#1-dynamic-resource-allocation-dra-driver)
   - [2. Scheduler Plugin](#2-scheduler-plugin)
   - [3. Node Capacity Updater DaemonSet](#3-node-capacity-updater-daemonset)
   - [4. Dynamic Memory Service](#4-dynamic-memory-service)
   - [5. Custom Resource Definitions (CRDs)](#5-custom-resource-definitions-crds)
   - [6. Kubectl Plugin](#6-kubectl-plugin)
   - [7. Metrics Exporter](#7-metrics-exporter)
4. [Workflow](#workflow)
   - [1. Pod Creation and Scheduling](#1-pod-creation-and-scheduling)
   - [2. Dynamic Memory Allocation](#2-dynamic-memory-allocation)
   - [3. Node Capacity Update](#3-node-capacity-update)
   - [4. Pod Execution](#4-pod-execution)
   - [5. Pod Termination and Resource Cleanup](#5-pod-termination-and-resource-cleanup)
5. [Component Interactions](#component-interactions)
6. [Security Considerations](#security-considerations)
7. [Scalability and Performance](#scalability-and-performance)
8. [Monitoring and Metrics](#monitoring-and-metrics)
9. [Conclusion](#conclusion)

---

## Introduction

The advent of Compute Express Link (CXL) Dynamic Capacity Devices (DCD) introduces the ability to dynamically add and remove memory at runtime without rebooting the host or restarting applications. Integrating this capability into Kubernetes requires a thoughtful architecture that leverages Kubernetes' extensibility while maintaining system stability and performance.

This document outlines the architecture designed to support dynamic memory capacities in Kubernetes clusters. The solution aims to:

- Enable pods to request dynamic memory resources.
- Allow Kubernetes to schedule pods based on both static and dynamically allocatable memory.
- Provision memory on-demand using a dynamic memory service.
- Update node capacities to reflect the newly provisioned memory.
- Integrate monitoring and management tools for visibility and control.

---

## High-Level Architecture

The architecture comprises several components that interact to facilitate dynamic memory allocation and management in a Kubernetes cluster.

```mermaid
flowchart TD
    subgraph Kubernetes Cluster
        A[User / Pod] -->|ResourceClaim| B[DRA Driver]
        B -->|Allocate Memory| C[Dynamic Memory Service]
        C -->|Provision Memory| D[Node]
        D -->|Update Capacity| E[Node Capacity Updater]
        E -->|Patch Node Status| F[Kubernetes API Server]
        B -->|Update Claim Status| F
        F -->|Schedule Pod| G[Scheduler Plugin]
        G -->|Bind Pod| D
    end
```

---

## Components

### 1. Dynamic Resource Allocation (DRA) Driver

**Purpose**: Handles dynamic memory allocation requests from pods and interfaces with the dynamic memory service to provision memory.

**Responsibilities**:

- Implements the DRA gRPC protocol.
- Processes `ResourceClaims` for dynamic memory.
- Communicates with the dynamic memory service via gRPC.
- Updates the status of `ResourceClaims` with allocation details.

**Diagram**:

```mermaid
classDiagram
    class DRADriver {
        +Allocate(ResourceClaim) error
        +Deallocate(ResourceClaim) error
        +ControllerWatch()
    }
    DRADriver --> DynamicMemoryService : gRPC Calls
    DRADriver --> KubernetesAPI : Update ResourceClaim Status
```

### 2. Scheduler Plugin

**Purpose**: Enhances the Kubernetes scheduler to consider dynamic memory when scheduling pods.

**Responsibilities**:

- Implements custom scheduling logic using the Scheduler Framework.
- Filters nodes based on their ability to allocate dynamic memory.
- Scores nodes based on dynamic memory provisioning criteria.

**Diagram**:

```mermaid
sequenceDiagram
    participant Scheduler
    participant SchedulerPlugin
    participant DRAController
    participant Node
    Scheduler->>SchedulerPlugin: Schedule Pod
    SchedulerPlugin->>DRAController: CanAllocateMemory?
    DRAController->>Node: Check Memory Capacity
    Node-->>DRAController: Capacity Info
    DRAController-->>SchedulerPlugin: Yes/No
    SchedulerPlugin-->>Scheduler: Filtered Node List
```

### 3. Node Capacity Updater DaemonSet

**Purpose**: Runs on each node to monitor actual memory capacity and update the node's status in the Kubernetes API.

**Responsibilities**:

- Communicates with the dynamic memory service to get current memory capacity.
- Updates `status.capacity` and `status.allocatable` fields of the node.
- Ensures the scheduler has up-to-date information.

**Diagram**:

```mermaid
flowchart LR
    A[Node Capacity Updater]
    B[Dynamic Memory Service]
    C[Kubernetes API Server]
    A -->|Get Capacity| B
    B -->|Memory Capacity| A
    A -->|Patch Node Status| C
```

### 4. Dynamic Memory Service

**Purpose**: External service that manages the provisioning and deprovisioning of dynamic memory on nodes.

**Responsibilities**:

- Receives requests to add or remove memory.
- Interacts with the underlying hardware (e.g., CXL DCD devices).
- Provides capacity information to the Node Capacity Updater.

**Diagram**:

```mermaid
classDiagram
    class DynamicMemoryService {
        +AddMemory(nodeID, amount) error
        +RemoveMemory(nodeID, amount) error
        +GetCapacity(nodeID) MemoryInfo
    }
```

### 5. Custom Resource Definitions (CRDs)

**Purpose**: Defines custom Kubernetes API objects for managing dynamic memory resources.

**Components**:

- **DynamicMemoryResource**: Represents the dynamic memory resource type.
- **DynamicMemoryClaim**: Represents a claim/request for dynamic memory by a pod.

**Diagram**:

```mermaid
erDiagram
    DynamicMemoryResource ||--o{ DynamicMemoryClaim : provides
    DynamicMemoryClaim {
        string namespace
        string name
        int memoryRequest
        string status
    }
```

### 6. Kubectl Plugin

**Purpose**: Extends `kubectl` with commands to manage and inspect dynamic memory resources.

**Features**:

- View dynamic memory allocations.
- Inspect `ResourceClaims` and their statuses.
- Debug allocation issues.

**Example Commands**:

- `kubectl dynamic-memory get claims`
- `kubectl dynamic-memory describe claim <name>`

### 7. Metrics Exporter

**Purpose**: Collects and exposes metrics related to dynamic memory usage for monitoring purposes.

**Responsibilities**:

- Exposes metrics via HTTP for Prometheus scraping.
- Provides insights into memory allocation, utilization, and errors.

**Key Metrics**:

- Total dynamic memory allocated per node.
- Number of successful/failed allocation requests.
- Memory provisioning latency.

---

## Workflow

### 1. Pod Creation and Scheduling

- **User** creates a pod that requires dynamic memory.
- **Pod Spec** includes a `ResourceClaim` for dynamic memory.
- **Scheduler Plugin** intercepts the scheduling process.

**Diagram**:

```mermaid
sequenceDiagram
    participant User
    participant APIserver
    participant Scheduler
    participant SchedulerPlugin
    User->>APIserver: Submit Pod with ResourceClaim
    APIserver->>Scheduler: Add Pod to Queue
    Scheduler->>SchedulerPlugin: Invoke Filter and Score Plugins
```

### 2. Dynamic Memory Allocation

- **Scheduler Plugin** determines if nodes can satisfy the dynamic memory request.
- **DRA Driver** processes the `ResourceClaim`.
- **DRA Driver** communicates with the **Dynamic Memory Service** to allocate memory.

**Diagram**:

```mermaid
sequenceDiagram
    participant SchedulerPlugin
    participant DRADriver
    participant DynamicMemoryService
    SchedulerPlugin->>DRADriver: Request Allocation
    DRADriver->>DynamicMemoryService: Allocate Memory
    DynamicMemoryService-->>DRADriver: Allocation Success/Failure
    DRADriver-->>SchedulerPlugin: Allocation Status
```

### 3. Node Capacity Update

- **Dynamic Memory Service** provisions memory on the node.
- **Node Capacity Updater** detects the new memory capacity.
- **Node Capacity Updater** updates the node status in the Kubernetes API.

**Diagram**:

```mermaid
sequenceDiagram
    participant Node
    participant NodeCapacityUpdater
    participant APIserver
    Node->>NodeCapacityUpdater: Memory Capacity Changed
    NodeCapacityUpdater->>APIserver: Patch Node Status
```

### 4. Pod Execution

- **Scheduler** binds the pod to the node with sufficient memory.
- **Kubelet** starts the pod on the node.
- Pod consumes the dynamically allocated memory during execution.

### 5. Pod Termination and Resource Cleanup

- **Pod** completes execution or is terminated.
- **DRA Driver** triggers deallocation of dynamic memory.
- **Dynamic Memory Service** releases the memory back to the pool.
- **Node Capacity Updater** updates the node status to reflect reduced capacity.

---

## Component Interactions

The following sequence diagram illustrates the end-to-end interaction between components during the lifecycle of a pod requesting dynamic memory.

```mermaid
sequenceDiagram
    participant User
    participant APIserver
    participant Scheduler
    participant SchedulerPlugin
    participant DRADriver
    participant DynamicMemoryService
    participant NodeCapacityUpdater
    participant Node
    User->>APIserver: Submit Pod with ResourceClaim
    APIserver->>Scheduler: Add Pod to Queue
    Scheduler->>SchedulerPlugin: Invoke Plugin
    SchedulerPlugin->>DRADriver: Can Allocate Memory?
    DRADriver->>DynamicMemoryService: Check Capacity
    DynamicMemoryService-->>DRADriver: Capacity Available
    DRADriver-->>SchedulerPlugin: Yes
    SchedulerPlugin-->>Scheduler: Node Suitable
    Scheduler->>APIserver: Bind Pod to Node
    DRADriver->>DynamicMemoryService: Allocate Memory
    DynamicMemoryService->>Node: Provision Memory
    Node->>NodeCapacityUpdater: Memory Capacity Changed
    NodeCapacityUpdater->>APIserver: Update Node Status
    APIserver->>Kubelet: Start Pod
    Kubelet->>Node: Run Pod
    Note over Node,Pod: Pod Execution
    Pod->>Kubelet: Termination Signal
    Kubelet->>DRADriver: Release Resources
    DRADriver->>DynamicMemoryService: Deallocate Memory
    DynamicMemoryService->>Node: Release Memory
    Node->>NodeCapacityUpdater: Memory Capacity Changed
    NodeCapacityUpdater->>APIserver: Update Node Status
```

---

## Security Considerations

- **Authentication and Authorization**:
  - Secure gRPC communications between components using mutual TLS.
  - Implement Kubernetes RBAC policies to control access to resources.
- **Data Integrity**:
  - Validate all inputs and outputs between components.
  - Ensure that the node status updates are accurate and authenticated.
- **Isolation**:
  - Use Kubernetes namespaces and network policies to isolate components.
  - Run components with the least privileges necessary.

---

## Scalability and Performance

- **Scalability**:
  - Components are designed to scale horizontally.
  - The DRA driver and scheduler plugin can handle multiple concurrent requests.
- **Performance**:
  - Use efficient communication protocols (gRPC) for low latency.
  - Cache capacity information where appropriate to reduce load on the dynamic memory service.

---

## Monitoring and Metrics

- **Metrics Exporter**:
  - Exposes Prometheus metrics for dynamic memory operations.
- **Key Metrics**:
  - `dynamic_memory_allocations_total`: Total number of memory allocations.
  - `dynamic_memory_allocation_errors_total`: Total number of allocation failures.
  - `dynamic_memory_current_usage_bytes`: Current dynamic memory usage per node.
- **Alerting**:
  - Set up alerts for high memory utilization or allocation failures.

**Diagram**:

```mermaid
flowchart LR
    A[Metrics Exporter] -->|Expose Metrics| B[Prometheus]
    B -->|Query| C[Grafana]
    C -->|Dashboards| D[User]
```