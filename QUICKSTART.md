# Guía de Inicio Rápido - ICAI INTROBBDD con k3s

Esta guía te ayudará a desplegar rápidamente las bases de datos ICAI INTROBBDD usando k3s.

## 📋 Pasos Rápidos

### 1. Preparar el Sistema

**Linux/macOS:**
```bash
# Instalar k3s
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Verificar instalación
k3s kubectl get nodes
```

**Windows:**
Instala k3s siguiendo la [documentación oficial](https://docs.k3s.io/installation/windows).

### 2. Desplegar

**Opción A - Helm Chart (Recomendado):**
```bash
# Instalar Helm si no está instalado
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Linux/macOS
./start-helm.sh

# Windows  
start-helm-windows.bat
```

**Opción B - Manifiestos k8s tradicionales:**
```bash
# Linux/macOS
./start-k3s.sh

# Windows  
start-k3s-windows.bat
```

**Opción C - Manual:**
```bash
# Con Helm
helm install icai-introbbdd ./icai-introbbdd --namespace introbbdd --create-namespace

# Con kubectl (tradicional)
kubectl apply -f k8s/all-in-one.yaml
kubectl wait --for=condition=available --timeout=300s deployment/mysql-deployment -n introbbdd
```

### 3. Conectar

**Información de conexión:**
- **Host:** localhost
- **Puerto:** 30306
- **Usuario:** root
- **Contraseña:** comillas

**Conexión desde línea de comandos:**
```bash
# Dentro del pod
kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas

# Desde tu máquina (si tienes MySQL client)
mysql -h localhost -P 30306 -u root -pcomillas
```

### 4. Verificar

```bash
# Verificar estado
kubectl get pods -n introbbdd

# Ejecutar tests
./test-k3s-deployment.sh

# Ver logs
kubectl logs deployment/mysql-deployment -n introbbdd
```

### 5. Limpiar

```bash
# Con Helm
./cleanup-helm.sh

# Con manifiestos tradicionales
./cleanup-k3s.sh

# O manual
helm uninstall icai-introbbdd -n introbbdd  # Para Helm
kubectl delete namespace introbbdd          # Para ambos
```

## 🗄️ Bases de Datos Disponibles

- **EMPLEADOS**: Centros, departamentos y empleados
- **BDAUTOBUSES**: Pasajeros, autobuses, trayectos y billetes

## 📁 Workspace

Tu directorio de trabajo está disponible en:
- **Local:** `$HOME/workspace` (Linux/macOS) o `%USERPROFILE%\workspace` (Windows)
- **Container:** `/workspace`

## ❓ Solución de Problemas

**Pod no inicia:**
```bash
kubectl describe pod -n introbbdd
kubectl logs deployment/mysql-deployment -n introbbdd
```

**No puedes conectar:**
```bash
# Verificar servicio
kubectl get svc -n introbbdd

# Port forward alternativo
kubectl port-forward svc/mysql-service 3306:3306 -n introbbdd
```

**Problemas de permisos:**
```bash
sudo chown -R $(whoami):$(whoami) /opt/icai-workspace
```

## 🔗 Más Información

Ver [README.md](README.md) para documentación completa.