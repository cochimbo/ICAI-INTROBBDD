# ICAI INTROBBDD - MySQL Database Practice Environment

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This repository provides MySQL databases for educational purposes using both Docker (legacy) and k3s deployment methods. The project contains two databases: EMPLEADOS (employees) and BDAUTOBUSES (bus transportation).

## Working Effectively

### Prerequisites Installation
**CRITICAL**: Install k3s first for main deployment method:
```bash
# Install k3s (takes 2-3 minutes) - NEVER CANCEL
curl -sfL https://get.k3s.io | sh - --write-kubeconfig-mode 644
# Verify installation
k3s kubectl get nodes
```

If k3s installation fails or is unavailable, Docker is available as fallback:
```bash
# Verify Docker is available
docker --version
# Pull MySQL image (takes ~11 seconds)
docker pull cochimbo/introbbddicade
```

### Primary Deployment (k3s - Recommended)
ALWAYS use k3s deployment for production-like environment:
```bash
# Deploy databases (takes 3-5 minutes) - NEVER CANCEL. Set timeout to 10+ minutes
./start-k3s.sh
# Wait for MySQL to be ready (up to 5 minutes) - NEVER CANCEL
kubectl wait --for=condition=available --timeout=300s deployment/mysql-deployment -n introbbdd
```

Alternative deployment using all-in-one manifest:
```bash
# Create required directories first
mkdir -p "$HOME/workspace"
sudo mkdir -p /opt/icai-mysql-data /opt/icai-workspace
sudo chown $(whoami):$(whoami) /opt/icai-workspace
# Deploy (takes 3-5 minutes) - NEVER CANCEL
kubectl apply -f k8s/all-in-one.yaml
```

### Fallback Deployment (Docker - Legacy)
If k3s is not available, use Docker deployment:
```bash
# Create volume and workspace (takes <1 minute)
docker volume create ICAIDATA
mkdir -p "$HOME/workspace"
# Run MySQL container (takes ~30 seconds to start) - NEVER CANCEL
docker run --name practicasbbdd -p 3306:3306 -v ICAIDATA:/var/lib/mysql -v "$HOME/workspace:/workspace" cochimbo/introbbddicade
# Wait 30-60 seconds for MySQL to be ready
```

### Database Initialization (Manual - Required for Docker)
**Docker deployments require manual database setup after container starts**:
```bash
# Wait 60 seconds for MySQL to be fully ready, then initialize EMPLEADOS database
sleep 60
docker exec practicasbbdd mysql -u root -pcomillas -e "source /empleados.sql"

# Create BDAUTOBUSES database manually (data loading has encoding issues with Spanish characters)
docker exec practicasbbdd mysql -u root -pcomillas -e "
DROP DATABASE IF EXISTS BDAUTOBUSES;
CREATE DATABASE BDAUTOBUSES;
USE BDAUTOBUSES;

CREATE TABLE PASAJEROS (
  DNI varchar(10) NOT NULL,
  NOMBRE varchar(25),
  TLFN varchar(9),
  PRIMARY KEY (DNI)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 

CREATE TABLE AUTOBUSES (
  MATRIC varchar(10) NOT NULL,
  NASIENTOS int(11) ,
  ITV date ,
  PRIMARY KEY (MATRIC)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE TRAYECTOS (
  CODTRAY varchar(10) NOT NULL,
  ORIG varchar(15),
  DEST varchar(15),
  PRECIO decimal(4,2),
  KM int(11),
  PRIMARY KEY (CODTRAY)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 

CREATE TABLE BILLETES (
  CBILL int(11) NOT NULL,
  CODTRAY char(8) NOT NULL,
  MATRIC char(7) NOT NULL,
  DNI char(10) NOT NULL,
  FECHA date DEFAULT NULL,
  HORA time,
  PRIMARY KEY (CBILL),
  KEY CODTRAY (CODTRAY),
  KEY MATRIC (MATRIC),
  KEY DNI (DNI),
  CONSTRAINT BILLETES_ibfk_1 FOREIGN KEY (CODTRAY) REFERENCES TRAYECTOS (CODTRAY) ON DELETE CASCADE,
  CONSTRAINT BILLETES_ibfk_2 FOREIGN KEY (MATRIC) REFERENCES AUTOBUSES (MATRIC) ON DELETE CASCADE,
  CONSTRAINT BILLETES_ibfk_3 FOREIGN KEY (DNI) REFERENCES PASAJEROS (DNI) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
"

# Note: Data loading for BDAUTOBUSES fails due to character encoding issues
# Tables are created but may be empty. Use manual INSERT statements if data is needed.
```

## Database Connection Information
- **MySQL Host**: localhost (Docker) or k3s node IP  
- **MySQL Port**: 3306 (Docker) or 30306 (k3s NodePort)
- **MySQL User**: root
- **MySQL Password**: comillas
- **Databases**: EMPLEADOS, BDAUTOBUSES
- **Workspace**: `$HOME/workspace` (host) mapped to `/workspace` (container)

## Validation and Testing

### ALWAYS Run These Validation Steps After Deployment
**CRITICAL**: Manual validation is required after any changes:

1. **Database Connectivity Test**:
```bash
# k3s deployment
kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "SHOW DATABASES;"
# Docker deployment  
docker exec practicasbbdd mysql -u root -pcomillas -e "SHOW DATABASES;"
```

2. **Database Content Validation**:
```bash
# k3s deployment
kubectl exec -it deployment/mysql-deployment -n introbbdd -- mysql -u root -pcomillas -e "USE EMPLEADOS; SELECT COUNT(*) as centers FROM TCENTR; SELECT COUNT(*) as departments FROM TDEPTO; SELECT COUNT(*) as employees FROM TEMPLE;"

# Docker deployment - EMPLEADOS should have 3 centers, 9 departments, 34 employees
docker exec practicasbbdd mysql -u root -pcomillas -e "USE EMPLEADOS; SELECT COUNT(*) as centers FROM TCENTR; SELECT COUNT(*) as departments FROM TDEPTO; SELECT COUNT(*) as employees FROM TEMPLE;"

# Check BDAUTOBUSES database structure (data may be empty due to encoding issues)
docker exec practicasbbdd mysql -u root -pcomillas -e "USE BDAUTOBUSES; SHOW TABLES; DESCRIBE PASAJEROS;"
```

3. **Workspace Volume Test**:
```bash
# Create test file on host
echo "Test from host at $(date)" > "$HOME/workspace/validation.txt"

# Verify accessible in container - k3s
kubectl exec -it deployment/mysql-deployment -n introbbdd -- cat /workspace/validation.txt

# Verify accessible in container - Docker
docker exec practicasbbdd cat /workspace/validation.txt
```

### Monitoring and Troubleshooting
```bash
# Check deployment status (k3s)
kubectl get pods,services -n introbbdd
kubectl logs -f deployment/mysql-deployment -n introbbdd

# Check container status (Docker)
docker ps
docker logs practicasbbdd

# Test connectivity
telnet localhost 3306  # Docker
telnet localhost 30306 # k3s
```

## Important File Locations

### Database Schema and Data
- `Empleados/empleados.sql` - EMPLEADOS database schema and data loading
- `Empleados/*.txt` - Employee data files (tcentr.txt, tdepto.txt, temple.txt)  
- `Autobuses/CrearBD.sql` - BDAUTOBUSES database schema
- `Autobuses/*` - Bus system data files (pasajeros, autobuses, trayectos, billetes)

### Deployment Configuration
- `k8s/` directory - All Kubernetes manifests
  - `k8s/namespace.yaml` - introbbdd namespace
  - `k8s/mysql-pv.yaml` - Persistent volumes
  - `k8s/mysql-pvc.yaml` - Persistent volume claims
  - `k8s/mysql-configmap.yaml` - Database initialization scripts
  - `k8s/mysql-deployment.yaml` - MySQL deployment
  - `k8s/mysql-service.yaml` - MySQL service (NodePort 30306)
- `k8s/all-in-one.yaml` - Combined deployment manifest
- `start-k3s.sh` - Main deployment script (Linux/macOS)
- `start-k3s-windows.bat` - Windows deployment script
- `test-k3s-deployment.sh` - Deployment validation script
- `cleanup-k3s.sh` - Cleanup script
- `create-combined-manifest.sh` - Script to generate all-in-one.yaml

### Legacy Files (Reference Only)
- `start-container.sh` - Legacy Docker deployment
- `start-container-windows.bat` - Legacy Docker deployment (Windows)
- `Dockerfile` - MySQL container definition (used by k3s but maintained separately)

## Build and Test Commands

### Testing Deployment  
```bash
# Run comprehensive k3s test suite (takes 2-3 minutes) - NEVER CANCEL
./test-k3s-deployment.sh

# Manual testing commands
# Check k3s deployment status
kubectl get all -n introbbdd
kubectl get pv,pvc -n introbbdd

# Check Docker deployment status  
docker ps
docker logs practicasbbdd
```

### Utility Scripts
```bash
# Generate combined k8s manifest
./create-combined-manifest.sh

# Alternative deployment methods
kubectl apply -f k8s/all-in-one.yaml  # All-in-one deployment
kubectl apply -f k8s/             # Individual manifests
```

### Cleanup
```bash
# k3s cleanup
kubectl delete namespace introbbdd
sudo rm -rf /opt/icai-mysql-data /opt/icai-workspace  # Optional: remove data

# Docker cleanup  
docker stop practicasbbdd && docker rm practicasbbdd
docker volume rm ICAIDATA  # Optional: remove data
```

## Common Issues and Solutions

### k3s Installation Fails
- Check if running in supported environment (Linux recommended)
- Verify Docker is not conflicting with k3s
- Use Docker fallback method

### Database Not Loading
- **For Docker**: manually run SQL scripts as shown above (wait 60 seconds after container start)
- **k3s deployments**: databases auto-initialize via ConfigMap scripts
- Check character encoding issues with Spanish characters in BDAUTOBUSES data
- Use `LOAD DATA INFILE` with proper file paths in `/var/lib/mysql-files/`
- BDAUTOBUSES data loading fails in Docker due to character encoding - tables created but empty

### Permission Issues
```bash
sudo chown -R $(whoami):$(whoami) /opt/icai-workspace
sudo chmod 755 /opt/icai-mysql-data /opt/icai-workspace
```

### Port Conflicts
- k3s uses NodePort 30306, Docker uses 3306
- Change port mapping if conflicts occur: `docker run -p 3307:3306`

## Performance Expectations
- **Docker image pull**: 10-15 seconds (subsequent pulls: <1 second if cached)
- **Container startup**: 60 seconds for full MySQL initialization 
- **k3s deployment**: 3-5 minutes total
- **Database initialization**: 1-2 minutes (Docker manual setup)
- **Test suite**: 2-3 minutes

**NEVER CANCEL** any deployment or initialization process. MySQL container takes ~60 seconds to fully initialize - wait for "ready for connections" message.

## Common Command Outputs

### Repository Structure
```
ls -la [repo-root]
Autobuses/               # BDAUTOBUSES database files
Dockerfile               # MySQL container definition  
Empleados/              # EMPLEADOS database files
QUICKSTART.md           # Quick start guide
README.md               # Main documentation
cleanup-k3s.sh          # Cleanup script
create-combined-manifest.sh  # Manifest generator
k8s/                    # Kubernetes manifests
start-container-windows.bat  # Legacy Docker (Windows)
start-container.sh      # Legacy Docker (Linux)  
start-k3s-windows.bat   # k3s deployment (Windows)
start-k3s.sh           # k3s deployment (Linux)
test-k3s-deployment.sh # Test script
```

### Database Structure
```
# EMPLEADOS database (after initialization)
mysql> USE EMPLEADOS; SHOW TABLES;
+---------------------+
| Tables_in_EMPLEADOS |
+---------------------+
| TCENTR              |  # Centers (3 rows)
| TDEPTO              |  # Departments (9 rows)  
| TEMPLE              |  # Employees (34 rows)
+---------------------+

# BDAUTOBUSES database (structure only)
mysql> USE BDAUTOBUSES; SHOW TABLES;
+-----------------------+
| Tables_in_BDAUTOBUSES |
+-----------------------+
| AUTOBUSES             |  # Buses
| BILLETES              |  # Tickets
| PASAJEROS             |  # Passengers
| TRAYECTOS             |  # Routes
+-----------------------+
```