#!/bin/bash

# ComputeSDK Server Deployment Script
set -e

ENVIRONMENT=${1:-development}
NAMESPACE_PREFIX=""

case $ENVIRONMENT in
  development)
    NAMESPACE_PREFIX="dev-"
    ;;
  staging)
    NAMESPACE_PREFIX="staging-"
    ;;
  production)
    NAMESPACE_PREFIX="prod-"
    ;;
  *)
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [development|staging|production]"
    exit 1
    ;;
esac

echo "🚀 Deploying ComputeSDK to $ENVIRONMENT environment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kustomize is available (or kubectl with kustomize support)
if ! kubectl kustomize --help &> /dev/null; then
    echo "❌ kubectl with kustomize support is required"
    exit 1
fi

# Deploy using kustomize
echo "📦 Applying manifests for $ENVIRONMENT..."
kubectl apply -k "manifests/overlays/$ENVIRONMENT"

echo "⏳ Waiting for deployments to be ready..."

# Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/${NAMESPACE_PREFIX}computesdk-api \
  deployment/${NAMESPACE_PREFIX}computesdk-gateway \
  deployment/${NAMESPACE_PREFIX}computesdk-sidekick \
  -n computesdk-system

echo "✅ ComputeSDK deployed successfully to $ENVIRONMENT!"
echo ""
echo "📋 Useful commands:"
echo "  kubectl get pods -n computesdk-system"
echo "  kubectl logs -f deployment/${NAMESPACE_PREFIX}computesdk-api -n computesdk-system"
echo "  kubectl port-forward svc/${NAMESPACE_PREFIX}computesdk-api 8080:8080 -n computesdk-system"
echo ""
echo "🔍 Check status:"
echo "  kubectl get all -n computesdk-system"