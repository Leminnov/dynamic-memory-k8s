# Contributing to the Dynamic Memory Kubernetes Project

Thank you for your interest in contributing to the Dynamic Memory Kubernetes project! Your contributions help improve the project and are greatly appreciated. This guide outlines the process for contributing code, documentation, and other improvements to the project.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Code of Conduct](#code-of-conduct)
3. [How to Contribute](#how-to-contribute)
   - [Reporting Issues](#reporting-issues)
   - [Feature Requests](#feature-requests)
   - [Submitting Changes](#submitting-changes)
4. [Development Environment Setup](#development-environment-setup)
   - [Prerequisites](#prerequisites)
   - [Clone the Repository](#clone-the-repository)
   - [Directory Structure](#directory-structure)
5. [Building the Project](#building-the-project)
6. [Running Tests](#running-tests)
7. [Coding Guidelines](#coding-guidelines)
   - [Code Style](#code-style)
   - [Commit Messages](#commit-messages)
   - [Pull Request Guidelines](#pull-request-guidelines)
8. [Documentation Contributions](#documentation-contributions)
9. [Community and Communication](#community-and-communication)
10. [License](#license)

---

## Getting Started

Before you begin contributing, please take a moment to familiarize yourself with the project's goals and architecture by reading the [README](../README.md) and the [Architecture Documentation](architecture.md).

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md). We are committed to providing a welcoming and inclusive environment for all contributors.

## How to Contribute

### Reporting Issues

If you encounter a bug or have a question, please check the [issue tracker](https://github.com/yourusername/dynamic-memory-k8s/issues) to see if it has already been reported. If not, you can open a new issue with the following information:

- **Description**: Provide a clear and concise description of the issue.
- **Steps to Reproduce**: Include steps to reproduce the problem.
- **Expected Behavior**: Describe what you expected to happen.
- **Actual Behavior**: Describe what actually happened.
- **Environment Details**: Include details about your environment (e.g., Kubernetes version, OS).

### Feature Requests

We welcome suggestions for new features or improvements. Please open an issue with the following:

- **Feature Description**: Explain the feature and why it would be useful.
- **Use Cases**: Describe how the feature would be used.
- **Possible Implementation**: If you have ideas about how to implement it, share them.

### Submitting Changes

We accept contributions via Pull Requests (PRs) on GitHub. Before submitting a PR:

1. **Discuss**: It's often helpful to discuss your plans via an issue or with maintainers to ensure alignment.
2. **Fork**: Fork the repository to your GitHub account.
3. **Branch**: Create a new branch for your changes (`git checkout -b my-feature`).
4. **Commit**: Commit your changes with clear commit messages.
5. **Push**: Push your branch to your fork (`git push origin my-feature`).
6. **Pull Request**: Open a PR against the `main` branch of the original repository.

## Development Environment Setup

### Prerequisites

- **Operating System**: Linux (Ubuntu 22.04 recommended)
- **Go**: Version 1.18 or later
- **Docker**: For building container images
- **Kubernetes Cluster**: For testing (e.g., Minikube, Kind)
- **Protocol Buffers Compiler**: `protoc` version 3.x
- **Go Tools**:
  - `protoc-gen-go`
  - `protoc-gen-go-grpc`

### Clone the Repository

```bash
git clone https://github.com/yourusername/dynamic-memory-k8s.git
cd dynamic-memory-k8s
```

### Directory Structure

The project is organized as follows:

```
dynamic-memory-k8s/
├── cmd/
│   ├── dra-driver/
│   ├── scheduler-plugin/
│   ├── node-capacity-updater/
│   └── kubectl-plugins/
├── pkg/
│   ├── api/
│   ├── controller/
│   ├── scheduler/
│   ├── updater/
│   └── grpc/
├── deployments/
├── charts/
├── configs/
├── scripts/
├── docs/
├── test/
├── examples/
├── api/
│   └── crds/
├── metrics/
├── hack/
├── LICENSE
├── .gitignore
├── go.mod
└── go.sum
```

Refer to the [Architecture Documentation](architecture.md) for more details.

## Building the Project

The project uses Go modules for dependency management. To build the binaries:

```bash
./scripts/build.sh
```

This script compiles the executables and places them in the `bin/` directory.

## Running Tests

Unit tests are located in the `test/unit/` directory, and integration tests are in `test/integration/`. To run all tests:

```bash
./scripts/test.sh
```

Ensure that tests pass before submitting a PR.

## Coding Guidelines

### Code Style

- **Go Formatting**: Use `go fmt` to format your code.
- **Linting**: Use `golangci-lint` to check for issues.
- **Idiomatic Go**: Follow best practices outlined in [Effective Go](https://golang.org/doc/effective_go.html).

### Commit Messages

- **Format**: Use the imperative mood in your commit messages (e.g., "Add feature", "Fix bug").
- **Structure**:
  - **Title**: Brief summary of the changes (max 50 characters).
  - **Body**: Detailed description of the changes and reasoning.
- **Reference Issues**: If applicable, reference related issues (e.g., `Fixes #123`).

### Pull Request Guidelines

- **One Feature per PR**: Keep changes focused and avoid combining unrelated changes.
- **Rebase**: Rebase your branch onto the latest `main` branch before submitting.
- **Description**: Provide a clear description of the changes and their purpose.
- **Checklist**:
  - Code compiles without errors.
  - Tests have been added or updated.
  - All tests pass.
  - Documentation has been updated accordingly.

## Documentation Contributions

We value high-quality documentation. You can contribute by:

- **Updating Existing Docs**: Improve clarity, fix typos, or update outdated information.
- **Adding New Docs**: Write new guides, tutorials, or FAQs.
- **Code Comments**: Ensure that public functions and packages have clear comments.

Documentation is located in the `docs/` directory. Use Markdown for all documentation files.

## Community and Communication

- **Issue Tracker**: Use GitHub issues for bugs, enhancements, and questions.
- **Pull Requests**: Use GitHub PRs for code submissions.
- **Discussions**: If available, use GitHub Discussions for broader conversations.

Please be respectful and considerate in all interactions.
