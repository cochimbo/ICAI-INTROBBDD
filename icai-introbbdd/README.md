# ICAI INTROBBDD Helm Chart

Este chart de Helm despliega las bases de datos MySQL EMPLEADOS y BDAUTOBUSES para el curso de Introducción a Bases de Datos del ICAI.

## Prerrequisitos

- Kubernetes cluster (k3s recomendado)
- Helm 3.x
- kubectl configurado

## Instalación Rápida

### Usando los scripts proporcionados:

```bash
# Linux/macOS
./start-helm.sh

# Windows
start-helm-windows.bat
```

### Instalación manual:

```bash
# Crear directorios de volúmenes persistentes
sudo mkdir -p /opt/icai-mysql-data /opt/icai-workspace
mkdir -p "$HOME/workspace"

# Instalar con Helm
helm install icai-introbbdd ./icai-introbbdd --namespace introbbdd --create-namespace
```

## Configuración

### Valores Principales (values.yaml)

| Parámetro | Descripción | Valor por Defecto |
|-----------|-------------|------------------|
| `mysql.image.repository` | Imagen Docker de MySQL | `cochimbo/introbbddicade` |
| `mysql.image.tag` | Tag de la imagen | `latest` |
| `mysql.auth.rootPassword` | Contraseña root de MySQL | `comillas` |
| `service.type` | Tipo de servicio Kubernetes | `NodePort` |
| `service.nodePort` | Puerto NodePort | `30306` |
| `persistence.mysqlData.size` | Tamaño del volumen de datos MySQL | `5Gi` |
| `persistence.workspace.size` | Tamaño del volumen workspace | `2Gi` |
| `resources.requests.memory` | Memoria solicitada | `512Mi` |
| `resources.limits.memory` | Límite de memoria | `1Gi` |

### Personalización de Valores

```bash
# Cambiar la contraseña de MySQL
helm upgrade icai-introbbdd ./icai-introbbdd --set mysql.auth.rootPassword=nuevapassword

# Cambiar recursos
helm upgrade icai-introbbdd ./icai-introbbdd \
    --set resources.requests.memory=1Gi \
    --set resources.limits.memory=2Gi

# Cambiar puerto NodePort
helm upgrade icai-introbbdd ./icai-introbbdd --set service.nodePort=30307
```

## Componentes Desplegados

El chart despliega los siguientes recursos:

- **Namespace**: `introbbdd`
- **PersistentVolumes**: Para datos MySQL y workspace
- **PersistentVolumeClaims**: Claims para los volúmenes
- **ConfigMap**: Scripts de inicialización de las bases de datos
- **Deployment**: Contenedor MySQL con las bases de datos
- **Service**: NodePort para acceso externo

## Bases de Datos

### EMPLEADOS
Contiene las siguientes tablas:
- `TCENTR`: Centros de trabajo
- `TDEPTO`: Departamentos
- `TEMPLE`: Empleados

### BDAUTOBUSES
Contiene las siguientes tablas:
- `PASAJEROS`: Información de pasajeros
- `AUTOBUSES`: Flota de autobuses
- `TRAYECTOS`: Rutas disponibles
- `BILLETES`: Billetes vendidos

## Conexión

### Información de Conexión:
- **Host**: localhost (o IP del nodo k3s)
- **Puerto**: 30306 (configurable)
- **Usuario**: root
- **Contraseña**: comillas (configurable)

### Conexión desde cliente MySQL:
```bash
mysql -h localhost -P 30306 -u root -pcomillas
```

### Conexión desde dentro del cluster:
```bash
kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas
```

## Comandos Útiles

### Estado del deployment:
```bash
helm status icai-introbbdd -n introbbdd
kubectl get all -n introbbdd
```

### Ver logs:
```bash
kubectl logs -f deployment/mysql-deployment -n introbbdd
```

### Port forwarding:
```bash
kubectl port-forward svc/mysql-service 3306:3306 -n introbbdd
```

### Ver valores actuales:
```bash
helm get values icai-introbbdd -n introbbdd
```

## Actualización

```bash
# Actualizar con nuevos valores
helm upgrade icai-introbbdd ./icai-introbbdd -n introbbdd

# Actualizar con valores personalizados
helm upgrade icai-introbbdd ./icai-introbbdd -n introbbdd \
    --set mysql.auth.rootPassword=nuevapass
```

## Desinstalación

### Usando el script:
```bash
./cleanup-helm.sh
```

### Manual:
```bash
# Desinstalar release
helm uninstall icai-introbbdd -n introbbdd

# Eliminar namespace (opcional)
kubectl delete namespace introbbdd

# Limpiar volúmenes persistentes (opcional)
sudo rm -rf /opt/icai-mysql-data /opt/icai-workspace
```

## Solución de Problemas

### Pod no inicia:
```bash
kubectl describe pod -n introbbdd
kubectl logs deployment/mysql-deployment -n introbbdd
```

### Problemas de permisos en volúmenes:
```bash
sudo chown -R $(whoami):$(whoami) /opt/icai-workspace
sudo chmod 755 /opt/icai-mysql-data /opt/icai-workspace
```

### Verificar chart antes de instalación:
```bash
./test-helm-chart.sh
helm template icai-introbbdd ./icai-introbbdd --debug
```

## Desarrollo

### Validar chart:
```bash
helm lint ./icai-introbbdd
```

### Renderizar templates:
```bash
helm template test-release ./icai-introbbdd --dry-run
```

### Ejecutar tests:
```bash
./test-helm-chart.sh
```