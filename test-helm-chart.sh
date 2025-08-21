#!/bin/bash

# Test script for ICAI INTROBBDD Helm charts
# This script validates the Helm chart without requiring a Kubernetes cluster

echo "🧪 Testing ICAI INTROBBDD Helm chart..."

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first:"
    echo "   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

CHART_PATH="./icai-introbbdd"

# Test 1: Check if chart exists
echo "📋 Test 1: Checking chart structure..."
if [[ ! -d "$CHART_PATH" ]]; then
    echo "❌ Helm chart not found at $CHART_PATH"
    exit 1
fi

required_files=("Chart.yaml" "values.yaml" "templates/namespace.yaml" "templates/deployment.yaml" "templates/service.yaml")
for file in "${required_files[@]}"; do
    if [[ ! -f "$CHART_PATH/$file" ]]; then
        echo "❌ Required file missing: $file"
        exit 1
    fi
done
echo "✅ Chart structure is valid"

# Test 2: Lint the chart
echo "📋 Test 2: Linting Helm chart..."
if helm lint "$CHART_PATH"; then
    echo "✅ Chart linting passed"
else
    echo "❌ Chart linting failed"
    exit 1
fi

# Test 3: Template rendering test
echo "📋 Test 3: Testing template rendering..."
output=$(helm template test-release "$CHART_PATH" 2>&1)
if [ $? -eq 0 ]; then
    echo "✅ Template rendering successful"
    
    # Test 4: Check for required resources in output
    echo "📋 Test 4: Validating rendered resources..."
    
    resources=("kind: Namespace" "kind: PersistentVolume" "kind: PersistentVolumeClaim" "kind: ConfigMap" "kind: Deployment" "kind: Service")
    for resource in "${resources[@]}"; do
        if echo "$output" | grep -q "$resource"; then
            echo "✅ Found $resource"
        else
            echo "❌ Missing $resource"
            exit 1
        fi
    done
    
    # Test 5: Check for proper namespacing
    echo "📋 Test 5: Checking namespace configuration..."
    if echo "$output" | grep -q "namespace: introbbdd"; then
        echo "✅ Namespace 'introbbdd' configured correctly"
    else
        echo "❌ Namespace configuration issue"
        exit 1
    fi
    
    # Test 6: Check MySQL configuration
    echo "📋 Test 6: Checking MySQL configuration..."
    if echo "$output" | grep -q "cochimbo/introbbddicade:latest"; then
        echo "✅ MySQL image configured correctly"
    else
        echo "❌ MySQL image configuration issue"
        exit 1
    fi
    
    if echo "$output" | grep -q "MYSQL_ROOT_PASSWORD"; then
        echo "✅ MySQL password configured"
    else
        echo "❌ MySQL password not configured"
        exit 1
    fi
    
    # Test 7: Check persistent volumes
    echo "📋 Test 7: Checking persistent volume configuration..."
    if echo "$output" | grep -q "/opt/icai-mysql-data"; then
        echo "✅ MySQL data volume path configured"
    else
        echo "❌ MySQL data volume path not configured"
        exit 1
    fi
    
    if echo "$output" | grep -q "/opt/icai-workspace"; then
        echo "✅ Workspace volume path configured"
    else
        echo "❌ Workspace volume path not configured"
        exit 1
    fi
    
    # Test 8: Check service configuration
    echo "📋 Test 8: Checking service configuration..."
    if echo "$output" | grep -q "nodePort: 30306"; then
        echo "✅ NodePort 30306 configured correctly"
    else
        echo "❌ NodePort configuration issue"
        exit 1
    fi
    
else
    echo "❌ Template rendering failed"
    echo "$output"
    exit 1
fi

# Test 9: Test with custom values
echo "📋 Test 9: Testing custom values..."
custom_output=$(helm template test-release "$CHART_PATH" --set mysql.auth.rootPassword=testpass --set service.nodePort=30307 2>&1)
if [ $? -eq 0 ]; then
    if echo "$custom_output" | grep -q "testpass" && echo "$custom_output" | grep -q "30307"; then
        echo "✅ Custom values applied correctly"
    else
        echo "❌ Custom values not applied"
        exit 1
    fi
else
    echo "❌ Custom values test failed"
    exit 1
fi

# Test 10: Check Chart.yaml metadata
echo "📋 Test 10: Validating Chart.yaml metadata..."
if grep -q "name: icai-introbbdd" "$CHART_PATH/Chart.yaml"; then
    echo "✅ Chart name is correct"
else
    echo "❌ Chart name issue"
    exit 1
fi

if grep -q "description:.*ICAI INTROBBDD" "$CHART_PATH/Chart.yaml"; then
    echo "✅ Chart description is informative"
else
    echo "❌ Chart description issue"
    exit 1
fi

echo ""
echo "🎉 All Helm chart tests passed!"
echo ""
echo "📊 Summary:"
echo "   ✅ Chart structure validated"
echo "   ✅ Lint checks passed"
echo "   ✅ Template rendering successful"
echo "   ✅ All required Kubernetes resources present"
echo "   ✅ Namespace configuration correct"
echo "   ✅ MySQL configuration valid"
echo "   ✅ Persistent volumes configured"
echo "   ✅ Service configuration correct"
echo "   ✅ Custom values functionality works"
echo "   ✅ Chart metadata valid"
echo ""
echo "🚀 The Helm chart is ready for deployment!"