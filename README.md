# Dynamic Memory Management for Kubernetes

This project implements a dynamic memory management solution for Kubernetes using Compute Express Link (CXL) Dynamic Capacity Devices (DCD). It extends Kubernetes to support dynamic memory allocation and deallocation without modifying core Kubernetes code.

## Features

- Custom scheduler plugin for dynamic memory-aware scheduling
- Dynamic Capacity Device (DCD) controller for managing memory resources
- kubectl plugin for easy management of dynamic memory
- Support for CXL-based memory expansion

## Getting Started

### Prerequisites

- Kubernetes cluster (version 1.29+)
- Go 1.21+
- Docker

### Installation

For detailed installation instructions, please refer to the [Installation Guide](docs/installation.md).

Quick start:

1. Clone the repository:
   ```
   git clone https://github.com/sscargal/dynamic-memory-k8s.git
   cd dynamic-memory-k8s
   ```

2. Build the project:
   ```
   ./scripts/build.sh
   ```

3. Install the components:
   ```
   ./scripts/install.sh
   ```

## Usage

For detailed usage instructions, please refer to the [User Guide](docs/user-guide.md).

Basic usage:

```
kubectl dynamic-memory list
kubectl dynamic-memory allocate <node> <size>
kubectl dynamic-memory deallocate <node> <size>
```

## Architecture

The system consists of the following main components:

1. Scheduler Plugin
2. DCD Controller
3. kubectl Plugin

For more details on the system architecture, please see the [Architecture Overview](docs/architecture.md).

## Configuration

Configuration files are located in the `/configs` directory. For detailed configuration options, please refer to the [Configuration Guide](docs/configuration.md).

## Development

For information on how to contribute to this project or set up a development environment, please see the [Development Guide](docs/CONTRIBUTING.md).

## Testing

To run the test suite:

```
./scripts/test.sh
```

For more information on testing, please refer to the [Testing Guide](docs/testing.md).

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, or request features.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For questions or support, please open an issue in the GitHub repository or contact the maintainers directly.
