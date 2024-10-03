# Configuration Guide

This document describes how to configure the dynamic memory management system for Kubernetes. The configuration files are located in the `/configs` directory of the project.

## Scheduler Configuration

File: `/configs/scheduler-config.yaml`

This file configures the Kubernetes scheduler to use the dynamic memory plugin.

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: dynamic-memory-scheduler
    plugins:
      filter:
        enabled:
          - name: DynamicMemory
      score:
        enabled:
          - name: DynamicMemory
    pluginConfig:
      - name: DynamicMemory
        args:
          # Your plugin configuration here
```

Adjust the `args` section to configure your dynamic memory plugin as needed.

## DCD Controller Configuration

File: `/configs/dcd-controller-config.yaml`

This ConfigMap configures the Dynamic Capacity Device (DCD) controller.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dcd-controller-config
  namespace: kube-system
data:
  config.yaml: |
    memoryOvercommitRatio: 1.2
    updateInterval: 30s
    # Add other configuration parameters as needed
```

- `memoryOvercommitRatio`: The ratio for memory overcommitment. Adjust based on your requirements.
- `updateInterval`: How often the controller updates its state.

## Custom Resource Definition

File: `/configs/crd-dynamicmemory.yaml`

This file defines the Custom Resource Definition (CRD) for dynamic memory.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: dynamicmemories.sscargal.com
spec:
  group: sscargal.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                capacity:
                  type: string
                  pattern: '^([0-9]+)(Ki|Mi|Gi|Ti|Pi|Ei)?$'
  scope: Namespaced
  names:
    plural: dynamicmemories
    singular: dynamicmemory
    kind: DynamicMemory
    shortNames:
    - dmem
```

This CRD defines a `DynamicMemory` resource with a `capacity` field. Adjust the schema as needed for your implementation.

## RBAC Configuration

File: `/configs/rbac.yaml`

This file sets up the necessary permissions for the dynamic memory controller.

```yaml
# Service Account, ClusterRole, and ClusterRoleBinding definitions here
```

Ensure that the permissions granted are sufficient for your controller's operations, but not overly broad.

## Deployment Configurations

### Scheduler Deployment

File: `/configs/deployment-scheduler.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dynamic-memory-scheduler
  namespace: kube-system
spec:
  # Deployment specifications here
```

Adjust the image name, resource requests/limits, and other parameters as needed.

### DCD Controller Deployment

File: `/configs/deployment-dcd-controller.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dcd-controller
  namespace: kube-system
spec:
  # Deployment specifications here
```

Adjust the image name, resource requests/limits, and other parameters as needed.

## Sample Pod Configuration

File: `/configs/sample-pod-with-dynamic-memory.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-memory-test-pod
spec:
  containers:
  - name: test-container
    image: nginx
    resources:
      requests:
        sscargal.com/dynamic-memory: 1Gi
      limits:
        sscargal.com/dynamic-memory: 2Gi
```

This sample configuration shows how to request dynamic memory for a pod. Adjust the resource name and quantities as needed.

## Applying Configurations

To apply these configurations:

1. Apply the CRD:
   ```
   kubectl apply -f /configs/crd-dynamicmemory.yaml
   ```

2. Apply RBAC rules:
   ```
   kubectl apply -f /configs/rbac.yaml
   ```

3. Create the DCD controller config:
   ```
   kubectl apply -f /configs/dcd-controller-config.yaml
   ```

4. Deploy the scheduler and DCD controller:
   ```
   kubectl apply -f /configs/deployment-scheduler.yaml
   kubectl apply -f /configs/deployment-dcd-controller.yaml
   ```

Remember to adjust these configurations based on your specific implementation and requirements. Always test configuration changes in a non-production environment before applying them to your production cluster.
