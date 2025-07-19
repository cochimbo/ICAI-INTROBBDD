#!/bin/bash

# k3s cleanup script for ICAI INTROBBDD

echo "🧹 Cleaning up ICAI INTROBBDD k3s deployment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    if command -v k3s &> /dev/null; then
        alias kubectl="k3s kubectl"
    else
        echo "❌ Neither kubectl nor k3s found. Cannot proceed with cleanup."
        exit 1
    fi
fi

# Delete the namespace (this removes all resources in it)
echo "🗑️  Deleting namespace and all resources..."
kubectl delete namespace introbbdd

echo "⏳ Waiting for namespace deletion..."
kubectl wait --for=delete namespace/introbbdd --timeout=60s

echo "🧹 Cleaning up persistent volume directories (requires sudo)..."
read -p "Do you want to delete persistent data? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /opt/icai-mysql-data
    sudo rm -rf /opt/icai-workspace
    echo "✅ Persistent data deleted."
else
    echo "⚠️  Persistent data preserved at /opt/icai-mysql-data and /opt/icai-workspace"
fi

echo "✅ Cleanup complete!"