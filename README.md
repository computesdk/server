# ComputeSDK Server

Production-ready Kubernetes manifests and deployment configurations for ComputeSDK.

## Repository Structure

```
manifests/
├── base/                    # Base Kustomize configurations
│   ├── api/                 # API service manifests
│   ├── gateway/             # Gateway service manifests  
│   ├── sidekick/            # Sidekick service manifests
│   ├── postgres/            # PostgreSQL database manifests
│   ├── rbac/                # Role-based access control
│   └── operators/           # Third-party operators
├── overlays/                # Environment-specific configurations
│   ├── development/         # Development environment
│   ├── staging/             # Staging environment
│   └── production/          # Production environment
scripts/                     # Deployment and utility scripts
docs/                        # Documentation
examples/                    # Example configurations
```

## Quick Start

### Prerequisites

- Kubernetes cluster (1.24+)
- kubectl configured
- kustomize (or kubectl with kustomize support)

### Deploy to Development

```bash
kubectl apply -k manifests/overlays/development
```

### Deploy to Production

```bash
kubectl apply -k manifests/overlays/production
```

## Components

- **API**: Core ComputeSDK API service
- **Gateway**: HTTP/WebSocket gateway for client connections
- **Sidekick**: Development environment management service
- **PostgreSQL**: Database using Zalando PostgreSQL Operator

## Configuration

Environment-specific configurations are managed through Kustomize overlays. Each environment can override:

- Resource limits and requests
- Replica counts
- Environment variables
- Ingress configurations
- Image tags

## Development

For local development, see the [operator repository](https://github.com/computesdk/operator) which contains simplified development manifests.

## Documentation

- [Deployment Guide](docs/deployment.md)
- [Configuration Reference](docs/configuration.md)

## Support

For issues and questions, please visit the [operator repository](https://github.com/computesdk/operator/issues).