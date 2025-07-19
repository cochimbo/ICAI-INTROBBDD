# ICAI INTROBBDD - k3s Deployment

Este proyecto ha sido migrado de Docker Compose a k3s para un mejor manejo de contenedores en entornos de Kubernetes.

## Descripción

El proyecto contiene dos bases de datos MySQL:
- **EMPLEADOS**: Base de datos con tablas de centros, departamentos y empleados
- **BDAUTOBUSES**: Base de datos con tablas de pasajeros, autobuses, trayectos y billetes

## Prerrequisitos

### Para Linux/macOS:
1. **k3s** instalado:
   ```bash
   curl -sfL https://get.k3s.io | sh -
   sudo chmod 644 /etc/rancher/k3s/k3s.yaml
   ```

2. **kubectl** (incluido con k3s):
   ```bash
   # k3s incluye kubectl, pero puedes aliasarlo si es necesario
   alias kubectl="k3s kubectl"
   ```

### Para Windows:
1. **k3s** instalado (consulta la documentación oficial de k3s para Windows)
2. **kubectl** disponible en el PATH

## Despliegue

### Linux/macOS:
```bash
./start-k3s.sh
```

### Windows:
```cmd
start-k3s-windows.bat
```

## Información de Conexión

Una vez desplegado, puedes conectarte a MySQL usando:

- **Host**: localhost (o la IP de tu nodo k3s)
- **Puerto**: 30306
- **Usuario**: root
- **Contraseña**: comillas
- **Bases de datos**: EMPLEADOS, BDAUTOBUSES

## Comandos Útiles

### Verificar el estado del despliegue:
```bash
kubectl get pods -n introbbdd
kubectl get services -n introbbdd
```

### Ver logs:
```bash
kubectl logs -f deployment/mysql-deployment -n introbbdd
```

### Conectarse a MySQL:
```bash
kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas
```

### Port forwarding (para conexión local):
```bash
kubectl port-forward svc/mysql-service 3306:3306 -n introbbdd
```

### Conectarse usando cliente MySQL externo:
```bash
mysql -h localhost -P 30306 -u root -pcomillas
```

## Estructura del Proyecto

```
├── k8s/                           # Manifiestos de Kubernetes
│   ├── namespace.yaml             # Namespace del proyecto
│   ├── mysql-pv.yaml              # Volúmenes persistentes
│   ├── mysql-pvc.yaml             # Claims de volúmenes persistentes
│   ├── mysql-configmap.yaml       # Scripts de inicialización
│   ├── mysql-deployment.yaml      # Despliegue de MySQL
│   └── mysql-service.yaml         # Servicio de MySQL
├── Empleados/                     # Datos de la BD EMPLEADOS
├── Autobuses/                     # Datos de la BD BDAUTOBUSES
├── Dockerfile                     # Imagen Docker (aún usada por k3s)
├── start-k3s.sh                   # Script de despliegue para Linux/macOS
├── start-k3s-windows.bat          # Script de despliegue para Windows
├── start-container.sh             # Script original Docker (legacy)
└── start-container-windows.bat    # Script original Docker (legacy)
```

## Volúmenes Persistentes

El despliegue crea dos volúmenes persistentes:

1. **mysql-data**: Para datos de MySQL (`/var/lib/mysql`)
   - Ubicación en el host: `/opt/icai-mysql-data`
   - Tamaño: 5Gi

2. **workspace**: Para archivos de trabajo (`/workspace`)
   - Ubicación en el host: `/opt/icai-workspace`
   - Tamaño: 2Gi
   - También mapeado a `$HOME/workspace` (Linux/macOS) o `%USERPROFILE%\workspace` (Windows)

## Limpieza

Para eliminar el despliegue:

```bash
kubectl delete namespace introbbdd
```

Para limpiar los volúmenes persistentes:
```bash
sudo rm -rf /opt/icai-mysql-data /opt/icai-workspace
```

## Migración desde Docker

Este proyecto reemplaza el setup anterior basado en Docker. Los archivos legacy (`start-container.sh` y `start-container-windows.bat`) se mantienen para referencia, pero se recomienda usar los nuevos scripts de k3s.

### Diferencias principales:
- **Antes**: `docker run` con volúmenes Docker
- **Ahora**: Despliegue k3s con PersistentVolumes
- **Beneficios**: Mejor escalabilidad, gestión declarativa, integración con ecosistema Kubernetes

## Solución de Problemas

### El pod no inicia:
```bash
kubectl describe pod -n introbbdd
kubectl logs deployment/mysql-deployment -n introbbdd
```

### Problemas de permisos:
```bash
sudo chown -R $(whoami):$(whoami) /opt/icai-workspace
sudo chmod 755 /opt/icai-mysql-data /opt/icai-workspace
```

### k3s no está corriendo:
```bash
sudo systemctl status k3s
sudo systemctl start k3s
```