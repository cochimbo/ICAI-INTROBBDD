@echo off
:: Helm deployment script for ICAI INTROBBDD on Windows

echo 🚀 Starting ICAI INTROBBDD Helm deployment...

:: Check if Helm is installed
helm version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Helm is not installed. Please install Helm first
    echo    Visit: https://helm.sh/docs/intro/install/
    pause
    exit /b 1
)

:: Check if kubectl is available
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl is not found. Please install kubectl or k3s first
    pause
    exit /b 1
)

:: Create workspace directory
echo 📁 Creating workspace directory...
if not exist %USERPROFILE%\workspace mkdir %USERPROFILE%\workspace

:: Configuration variables
set CHART_PATH=.\icai-introbbdd
set RELEASE_NAME=icai-introbbdd
set NAMESPACE=introbbdd

:: Check if chart exists
if not exist %CHART_PATH% (
    echo ❌ Helm chart not found at %CHART_PATH%
    echo    Please make sure you're running this script from the repository root.
    pause
    exit /b 1
)

:: Validate the Helm chart
echo 🔍 Validating Helm chart...
helm lint %CHART_PATH%
if %errorlevel% neq 0 (
    echo ❌ Helm chart validation failed
    pause
    exit /b 1
)

:: Deploy using Helm
echo 🔧 Deploying with Helm...
helm upgrade --install %RELEASE_NAME% %CHART_PATH% --namespace %NAMESPACE% --create-namespace --wait --timeout=300s

if %errorlevel% equ 0 (
    echo ✅ Deployment complete!
    echo.
    echo 📋 Connection information:
    echo    MySQL Host: localhost (or your k3s node IP^)
    echo    MySQL Port: 30306
    echo    MySQL User: root
    echo    MySQL Password: comillas
    echo    Databases: EMPLEADOS, BDAUTOBUSES
    echo    Workspace: %USERPROFILE%\workspace (mounted to /workspace in container^)
    echo.
    echo 🔍 Useful commands:
    echo    kubectl get pods -n %NAMESPACE%                           # Check pod status
    echo    kubectl logs -f deployment/mysql-deployment -n %NAMESPACE%  # View logs
    echo    kubectl port-forward svc/mysql-service 3306:3306 -n %NAMESPACE%  # Port forward
    echo    kubectl exec -it deployment/mysql-deployment -n %NAMESPACE% -- mysql -u root -pcomillas  # Connect to MySQL
    echo    helm status %RELEASE_NAME% -n %NAMESPACE%                  # Check Helm release status
    echo    helm get values %RELEASE_NAME% -n %NAMESPACE%              # View current values
    echo.
    echo 📋 To customize the deployment, edit values in icai-introbbdd\values.yaml or use --set flags
    echo 📋 To upgrade: helm upgrade %RELEASE_NAME% %CHART_PATH% -n %NAMESPACE%
    echo 📋 To uninstall: helm uninstall %RELEASE_NAME% -n %NAMESPACE%
) else (
    echo ❌ Deployment failed
    pause
    exit /b 1
)

pause