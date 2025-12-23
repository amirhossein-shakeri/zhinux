# Zhinux

A cloud-native microservices platform built with Go, gRPC, and Kubernetes.

## Repository Structure

This is a meta-repository containing documentation and references to individual service repositories.

### Core Repositories

- **[zhinux-hello](https://github.com/amirhossein-shakeri/zhinux-hello)** - Example gRPC service
- **[zhinux-platform](https://github.com/amirhossein-shakeri/zhinux-platform)** - Shared platform utilities
- **[zhinux-contracts](https://github.com/amirhossein-shakeri/zhinux-contracts)** - Protocol definitions and events

### Documentation

- [Guides](docs/guides/) - Getting started and development guides
- [Standards](docs/standards/) - Development standards and best practices

## Getting Started

1. Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/amirhossein-shakeri/zhinux.git
```

1. Or if already cloned:

```bash
git submodule update --init --recursive
```

1. Follow the [onboarding guide](zhinux-docs/guides/onboarding.md)
