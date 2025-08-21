#!/bin/bash

# Helm deployment script for ICAI INTROBBDD
# This script deploys the MySQL databases using Helm charts

echo "🚀 Starting ICAI INTROBBDD Helm deployment..."

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first:"
    echo "   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    if command -v k3s &> /dev/null; then
        echo "📋 Using k3s kubectl..."
        alias kubectl="k3s kubectl"
    else
        echo "❌ Neither kubectl nor k3s found. Please install k3s or kubectl first."
        exit 1
    fi
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

# Configuration variables
CHART_PATH="./icai-introbbdd"
RELEASE_NAME="icai-introbbdd"
NAMESPACE="introbbdd"

# Check if chart exists
if [[ ! -d "$CHART_PATH" ]]; then
    echo "❌ Helm chart not found at $CHART_PATH"
    echo "   Please make sure you're running this script from the repository root."
    exit 1
fi

# Validate the Helm chart
echo "🔍 Validating Helm chart..."
if ! helm lint "$CHART_PATH"; then
    echo "❌ Helm chart validation failed"
    exit 1
fi

# Deploy using Helm
echo "🔧 Deploying with Helm..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --wait \
    --timeout=300s

if [ $? -eq 0 ]; then
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
    echo "   kubectl get pods -n $NAMESPACE          # Check pod status"
    echo "   kubectl logs -f deployment/mysql-deployment -n $NAMESPACE  # View logs"
    echo "   kubectl port-forward svc/mysql-service 3306:3306 -n $NAMESPACE  # Port forward"
    echo "   kubectl exec -it deployment/mysql-deployment -n $NAMESPACE -- mysql -u root -pcomillas  # Connect to MySQL"
    echo "   helm status $RELEASE_NAME -n $NAMESPACE  # Check Helm release status"
    echo "   helm get values $RELEASE_NAME -n $NAMESPACE  # View current values"
    echo ""
    echo "📋 To customize the deployment, edit values in icai-introbbdd/values.yaml or use --set flags"
    echo "📋 To upgrade: helm upgrade $RELEASE_NAME $CHART_PATH -n $NAMESPACE"
    echo "📋 To uninstall: helm uninstall $RELEASE_NAME -n $NAMESPACE"
else
    echo "❌ Deployment failed"
    exit 1
fi