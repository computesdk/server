# Configuration Reference

This document describes how to configure ComputeSDK deployments using Kustomize overlays.

## Overview

ComputeSDK uses Kustomize for configuration management, allowing environment-specific customizations while maintaining a common base.

## Base Configuration

Base manifests in `manifests/base/` define the core ComputeSDK deployment:

- **API Service**: Core REST API and business logic
- **Gateway Service**: HTTP/WebSocket proxy and routing
- **Sidekick Service**: Development environment sidecar
- **PostgreSQL**: Database using Zalando operator
- **RBAC**: Role-based access control

## Environment Overlays

### Development (`manifests/overlays/development/`)

Optimized for local development and testing:

```yaml
# Resource limits
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# Environment variables
env:
  - name: LOG_LEVEL
    value: "debug"
  - name: ENVIRONMENT
    value: "development"

# Image tags
images:
  - name: ghcr.io/computesdk/api
    newTag: dev
```

### Staging (`manifests/overlays/staging/`)

Pre-production testing environment:

```yaml
# Moderate resources
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"

# Production-like settings
env:
  - name: LOG_LEVEL
    value: "info"
  - name: ENVIRONMENT
    value: "staging"
```

### Production (`manifests/overlays/production/`)

High-availability production deployment:

```yaml
# High resources and replicas
replicas: 3
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "2000m"

# Production optimizations
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 30
readinessProbe:
  initialDelaySeconds: 30
  periodSeconds: 15
```

## Customization Patterns

### Adding Environment Variables

Create or modify patch files in overlay directories:

```yaml
# manifests/overlays/production/api-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: computesdk-api
spec:
  template:
    spec:
      containers:
        - name: computesdk-api
          env:
            - name: CUSTOM_SETTING
              value: "production-value"
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: api-secrets
                  key: secret-key
```

### Scaling Services

Adjust replica counts per environment:

```yaml
# manifests/overlays/production/api-patch.yaml
spec:
  replicas: 5  # Scale API service to 5 replicas
```

### Resource Tuning

Customize CPU and memory limits:

```yaml
spec:
  template:
    spec:
      containers:
        - name: computesdk-api
          resources:
            requests:
              memory: "1Gi"
              cpu: "1000m"
            limits:
              memory: "4Gi"
              cpu: "4000m"
```

### Image Management

Control image tags and registries:

```yaml
# manifests/overlays/production/kustomization.yaml
images:
  - name: ghcr.io/computesdk/api
    newTag: v1.2.3
  - name: ghcr.io/computesdk/gateway
    newTag: v1.2.3
  - name: ghcr.io/computesdk/sidekick
    newTag: v1.2.3
```

### Adding Secrets

Create secret manifests and reference them:

```yaml
# manifests/overlays/production/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
  namespace: computesdk-system
type: Opaque
data:
  secret-key: <base64-encoded-value>
```

```yaml
# manifests/overlays/production/kustomization.yaml
resources:
  - ../../base
  - secrets.yaml
```

### Ingress Configuration

Add ingress for external access:

```yaml
# manifests/overlays/production/ingress-patch.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: computesdk-ingress
spec:
  rules:
    - host: api.computesdk.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: computesdk-api
                port:
                  number: 8080
```

## Database Configuration

### PostgreSQL Operator Settings

Customize database resources and configuration:

```yaml
# manifests/overlays/production/postgres-patch.yaml
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: computesdk-postgres
spec:
  numberOfInstances: 3  # High availability
  volume:
    size: 100Gi  # Larger storage
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 4Gi
```

## Monitoring and Observability

### Adding Prometheus Monitoring

```yaml
# manifests/overlays/production/monitoring-patch.yaml
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
```

### Log Configuration

Control logging levels per environment:

```yaml
env:
  - name: LOG_LEVEL
    value: "info"  # debug, info, warn, error
  - name: LOG_FORMAT
    value: "json"  # json, text
```

## Best Practices

1. **Environment Parity**: Keep environments as similar as possible
2. **Resource Limits**: Always set resource limits to prevent resource starvation
3. **Health Checks**: Configure appropriate health check timeouts
4. **Secrets Management**: Use Kubernetes secrets for sensitive data
5. **Image Tags**: Use specific tags in production, avoid `latest`
6. **Monitoring**: Enable monitoring and logging in all environments
7. **Backup**: Configure database backups for production

## Validation

Validate configurations before applying:

```bash
# Dry run validation
kubectl kustomize manifests/overlays/production --dry-run=client

# Apply with validation
kubectl apply -k manifests/overlays/production --dry-run=client
```