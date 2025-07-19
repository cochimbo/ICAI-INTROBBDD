#!/bin/bash

# k3s deployment script for ICAI INTROBBDD
# This script replaces the original Docker setup with k3s

echo "🚀 Starting ICAI INTROBBDD k3s deployment..."

# Check if k3s is installed
if ! command -v k3s &> /dev/null; then
    echo "❌ k3s is not installed. Please install k3s first:"
    echo "   curl -sfL https://get.k3s.io | sh -"
    echo "   sudo chmod 644 /etc/rancher/k3s/k3s.yaml"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not found. Using k3s kubectl..."
    alias kubectl="k3s kubectl"
fi

# Create the workspace directory
echo "📁 Creating workspace directory..."
mkdir -p "$HOME/workspace"

# Create persistent volume directories
echo "📁 Creating persistent volume directories..."
sudo mkdir -p /opt/icai-mysql-data
sudo mkdir -p /opt/icai-workspace
sudo chown $(whoami):$(whoami) /opt/icai-workspace
sudo chmod 755 /opt/icai-mysql-data /opt/icai-workspace

# Apply Kubernetes manifests
echo "🔧 Applying Kubernetes manifests..."

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-configmap.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml

echo "⏳ Waiting for MySQL deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mysql-deployment -n introbbdd

echo "✅ Deployment complete!"
echo ""
echo "📋 Connection information:"
echo "   MySQL Host: localhost (or your k3s node IP)"
echo "   MySQL Port: 30306"
echo "   MySQL User: root"
echo "   MySQL Password: comillas"
echo "   Databases: EMPLEADOS, BDAUTOBUSES"
echo "   Workspace: $HOME/workspace (mounted to /workspace in container)"
echo ""
echo "🔍 Useful commands:"
echo "   kubectl get pods -n introbbdd          # Check pod status"
echo "   kubectl logs -f deployment/mysql-deployment -n introbbdd  # View logs"
echo "   kubectl port-forward svc/mysql-service 3306:3306 -n introbbdd  # Port forward"
echo "   kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas  # Connect to MySQL"