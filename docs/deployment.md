# ComputeSDK Deployment Guide

This guide covers deploying ComputeSDK to various environments using the manifests in this repository.

## Repository Structure

This repository contains **production-ready** Kubernetes manifests and deployment configurations. For development, see the [operator repository](https://github.com/computesdk/operator).

### Separation of Concerns

- **[computesdk/operator](https://github.com/computesdk/operator)**: Source code, development manifests, testing
- **[computesdk/server](https://github.com/computesdk/server)**: Production manifests, deployment automation, infrastructure

## Prerequisites

- Kubernetes cluster (1.24+)
- kubectl configured with cluster access
- kustomize (or kubectl with kustomize support)
- Zalando PostgreSQL Operator (installed via setup script)

## Quick Start

### 1. Setup Cluster Prerequisites

```bash
./scripts/setup-cluster.sh
```

This installs:
- Zalando PostgreSQL Operator
- Required cluster-wide RBAC
- computesdk-system namespace

### 2. Deploy to Environment

```bash
# Development
./scripts/deploy.sh development

# Staging  
./scripts/deploy.sh staging

# Production
./scripts/deploy.sh production
```

### 3. Verify Deployment

```bash
kubectl get all -n computesdk-system
kubectl logs -f deployment/computesdk-api -n computesdk-system
```

## Environment Configurations

### Development
- **Replicas**: 1 for all services
- **Resources**: Minimal (128Mi RAM, 100m CPU)
- **Image Tags**: `dev`
- **Logging**: Debug level

### Staging
- **Replicas**: 1-2 per service
- **Resources**: Moderate (256Mi-1Gi RAM, 150m-1000m CPU)
- **Image Tags**: `staging`
- **Logging**: Info level

### Production
- **Replicas**: 2-3 per service
- **Resources**: High (512Mi-2Gi RAM, 500m-2000m CPU)
- **Image Tags**: `stable`
- **Logging**: Info level
- **Enhanced**: Longer health check timeouts

## Manual Deployment

If you prefer manual control:

```bash
# Apply base manifests
kubectl apply -k manifests/base

# Or apply specific environment
kubectl apply -k manifests/overlays/production
```

## Customization

### Image Tags

Update image tags in overlay kustomization.yaml files:

```yaml
images:
  - name: ghcr.io/computesdk/api
    newTag: v1.2.3
```

### Resource Limits

Modify patch files in overlay directories:

```yaml
# manifests/overlays/production/api-patch.yaml
spec:
  template:
    spec:
      containers:
        - name: computesdk-api
          resources:
            limits:
              memory: "4Gi"
              cpu: "2000m"
```

### Environment Variables

Add environment-specific variables in patch files:

```yaml
env:
  - name: CUSTOM_CONFIG
    value: "production-value"
```

## Troubleshooting

### Common Issues

1. **PostgreSQL not ready**: Wait for postgres operator to create the cluster
2. **Image pull errors**: Ensure container registry access
3. **RBAC errors**: Run setup-cluster.sh to install prerequisites

### Useful Commands

```bash
# Check pod status
kubectl get pods -n computesdk-system

# View logs
kubectl logs -f deployment/computesdk-api -n computesdk-system

# Port forward for testing
kubectl port-forward svc/computesdk-api 8080:8080 -n computesdk-system

# Describe resources
kubectl describe deployment computesdk-api -n computesdk-system
```

## Cleanup

```bash
# Remove specific environment
./scripts/cleanup.sh production

# Complete removal (careful!)
kubectl delete namespace computesdk-system
```

## CI/CD Integration

The repository includes GitHub Actions for:
- Manifest validation
- Kustomize dry-run testing
- YAML syntax checking

See `.github/workflows/validate.yml` for details.