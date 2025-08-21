#!/bin/bash

# Helm cleanup script for ICAI INTROBBDD

echo "🧹 Cleaning up ICAI INTROBBDD Helm deployment..."

# Configuration variables
RELEASE_NAME="icai-introbbdd"
NAMESPACE="introbbdd"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    if command -v k3s &> /dev/null; then
        alias kubectl="k3s kubectl"
    else
        echo "❌ Neither kubectl nor k3s found."
        exit 1
    fi
fi

# Check if the release exists
if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    echo "🗑️  Uninstalling Helm release '$RELEASE_NAME'..."
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
    
    if [ $? -eq 0 ]; then
        echo "✅ Helm release uninstalled successfully"
    else
        echo "❌ Failed to uninstall Helm release"
        exit 1
    fi
else
    echo "ℹ️  Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
fi

# Optionally delete the namespace
echo ""
read -p "Do you want to delete the namespace '$NAMESPACE'? (y/N): " delete_namespace
if [[ $delete_namespace =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting namespace '$NAMESPACE'..."
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
    echo "✅ Namespace deleted"
fi

# Optionally clean up persistent volume directories
echo ""
read -p "Do you want to clean up persistent volume data? This will DELETE all database data! (y/N): " delete_data
if [[ $delete_data =~ ^[Yy]$ ]]; then
    echo "🗑️  Cleaning up persistent volume directories..."
    sudo rm -rf /opt/icai-mysql-data /opt/icai-workspace
    echo "✅ Persistent volume data cleaned up"
    echo "⚠️  All database data has been permanently deleted!"
fi

echo ""
echo "🎉 Cleanup completed!"