#!/bin/bash

# ComputeSDK Cleanup Script
set -e

ENVIRONMENT=${1:-development}

case $ENVIRONMENT in
  development|staging|production)
    ;;
  *)
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [development|staging|production]"
    exit 1
    ;;
esac

echo "🗑️  Cleaning up ComputeSDK $ENVIRONMENT environment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Delete using kustomize
echo "📦 Removing manifests for $ENVIRONMENT..."
kubectl delete -k "manifests/overlays/$ENVIRONMENT" --ignore-not-found=true

echo "✅ ComputeSDK $ENVIRONMENT environment cleaned up!"
echo ""
echo "ℹ️  Note: This does not remove:"
echo "  - The computesdk-system namespace (may contain other resources)"
echo "  - PostgreSQL operator (cluster-wide resource)"
echo "  - Persistent volumes (data safety)"
echo ""
echo "🗑️  To completely remove everything:"
echo "  kubectl delete namespace computesdk-system"