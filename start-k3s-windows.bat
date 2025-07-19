@echo off
REM k3s deployment script for ICAI INTROBBDD (Windows)
REM This script replaces the original Docker setup with k3s

echo 🚀 Starting ICAI INTROBBDD k3s deployment...

REM Check if kubectl is available
kubectl version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl is not found. Please ensure k3s is installed and kubectl is in your PATH.
    echo    For Windows, you can install k3s using:
    echo    https://docs.k3s.io/installation/windows
    pause
    exit /b 1
)

REM Create the workspace directory
echo 📁 Creating workspace directory...
if not exist %USERPROFILE%\workspace mkdir %USERPROFILE%\workspace

REM Note: On Windows, you'll need to manually create the persistent volume directories
echo ⚠️  Note: Please ensure the following directories exist on your k3s node:
echo    /opt/icai-mysql-data
echo    /opt/icai-workspace

REM Apply Kubernetes manifests
echo 🔧 Applying Kubernetes manifests...

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-configmap.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml

echo ⏳ Waiting for MySQL deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/mysql-deployment -n introbbdd

echo ✅ Deployment complete!
echo.
echo 📋 Connection information:
echo    MySQL Host: localhost (or your k3s node IP)
echo    MySQL Port: 30306
echo    MySQL User: root
echo    MySQL Password: comillas
echo    Databases: EMPLEADOS, BDAUTOBUSES
echo    Workspace: %USERPROFILE%\workspace (mounted to /workspace in container)
echo.
echo 🔍 Useful commands:
echo    kubectl get pods -n introbbdd          # Check pod status
echo    kubectl logs -f deployment/mysql-deployment -n introbbdd  # View logs
echo    kubectl port-forward svc/mysql-service 3306:3306 -n introbbdd  # Port forward
echo    kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas  # Connect to MySQL

pause