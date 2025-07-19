#!/bin/bash

# Test script for ICAI INTROBBDD k3s deployment
# This script verifies that the deployment is working correctly

echo "🧪 Testing ICAI INTROBBDD k3s deployment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    if command -v k3s &> /dev/null; then
        alias kubectl="k3s kubectl"
    else
        echo "❌ Neither kubectl nor k3s found. Cannot run tests."
        exit 1
    fi
fi

# Test 1: Check if namespace exists
echo "📋 Test 1: Checking namespace..."
if kubectl get namespace introbbdd >/dev/null 2>&1; then
    echo "✅ Namespace 'introbbdd' exists"
else
    echo "❌ Namespace 'introbbdd' not found"
    exit 1
fi

# Test 2: Check if all pods are running
echo "📋 Test 2: Checking pod status..."
kubectl get pods -n introbbdd
pod_status=$(kubectl get pods -n introbbdd -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
if [ "$pod_status" = "Running" ]; then
    echo "✅ MySQL pod is running"
else
    echo "❌ MySQL pod is not running (status: $pod_status)"
    kubectl describe pods -n introbbdd
    exit 1
fi

# Test 3: Check if service is accessible
echo "📋 Test 3: Checking service..."
if kubectl get service mysql-service -n introbbdd >/dev/null 2>&1; then
    echo "✅ MySQL service exists"
    kubectl get service mysql-service -n introbbdd
else
    echo "❌ MySQL service not found"
    exit 1
fi

# Test 4: Test database connectivity
echo "📋 Test 4: Testing database connectivity..."
# Try to connect to MySQL and run a simple query
if kubectl exec deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "SHOW DATABASES;" >/dev/null 2>&1; then
    echo "✅ MySQL is accepting connections"
    
    # Test 5: Check if our databases exist
    echo "📋 Test 5: Checking databases..."
    databases=$(kubectl exec deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "SHOW DATABASES;" 2>/dev/null)
    
    if echo "$databases" | grep -q "EMPLEADOS"; then
        echo "✅ EMPLEADOS database exists"
    else
        echo "❌ EMPLEADOS database not found"
    fi
    
    if echo "$databases" | grep -q "BDAUTOBUSES"; then
        echo "✅ BDAUTOBUSES database exists"
    else
        echo "❌ BDAUTOBUSES database not found"
    fi
    
    # Test 6: Check tables in EMPLEADOS
    echo "📋 Test 6: Checking EMPLEADOS tables..."
    empleados_tables=$(kubectl exec deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "USE EMPLEADOS; SHOW TABLES;" 2>/dev/null)
    
    for table in TCENTR TDEPTO TEMPLE; do
        if echo "$empleados_tables" | grep -q "$table"; then
            echo "✅ Table $table exists in EMPLEADOS"
        else
            echo "❌ Table $table not found in EMPLEADOS"
        fi
    done
    
    # Test 7: Check tables in BDAUTOBUSES  
    echo "📋 Test 7: Checking BDAUTOBUSES tables..."
    autobuses_tables=$(kubectl exec deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "USE BDAUTOBUSES; SHOW TABLES;" 2>/dev/null)
    
    for table in PASAJEROS AUTOBUSES TRAYECTOS BILLETES; do
        if echo "$autobuses_tables" | grep -q "$table"; then
            echo "✅ Table $table exists in BDAUTOBUSES"
        else
            echo "❌ Table $table not found in BDAUTOBUSES"
        fi
    done
    
else
    echo "❌ Cannot connect to MySQL"
    kubectl logs deployment/mysql-deployment -n introbbdd --tail=20
    exit 1
fi

# Test 8: Check persistent volumes
echo "📋 Test 8: Checking persistent volumes..."
if kubectl get pv mysql-data-pv >/dev/null 2>&1; then
    echo "✅ MySQL data PV exists"
else
    echo "❌ MySQL data PV not found"
fi

if kubectl get pv workspace-pv >/dev/null 2>&1; then
    echo "✅ Workspace PV exists"
else
    echo "❌ Workspace PV not found"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "📋 Summary:"
kubectl get all -n introbbdd
echo ""
echo "💾 Storage:"
kubectl get pv,pvc -n introbbdd