#!/bin/bash

# ComputeSDK Cluster Setup Script
# Sets up prerequisites for ComputeSDK deployment

set -e

echo "🔧 Setting up ComputeSDK cluster prerequisites..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Create namespace if it doesn't exist
echo "📦 Creating computesdk-system namespace..."
kubectl create namespace computesdk-system --dry-run=client -o yaml | kubectl apply -f -

# Install Zalando PostgreSQL Operator (if not already installed)
echo "🐘 Setting up PostgreSQL operator..."
if ! kubectl get crd postgresqls.acid.zalan.do &> /dev/null; then
    echo "Installing Zalando PostgreSQL operator..."
    kubectl apply -k github.com/zalando/postgres-operator/manifests
    
    echo "⏳ Waiting for PostgreSQL operator to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/postgres-operator -n default
else
    echo "PostgreSQL operator already installed"
fi

# Apply any additional cluster-wide resources
echo "🔐 Setting up cluster-wide RBAC..."
# Add any cluster-wide RBAC or other resources here if needed

echo "✅ Cluster setup complete!"
echo ""
echo "🚀 Ready to deploy ComputeSDK:"
echo "  ./deploy.sh development"
echo "  ./deploy.sh staging"
echo "  ./deploy.sh production"