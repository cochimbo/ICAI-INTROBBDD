#!/bin/bash

# Create a single manifest file that combines all k8s resources
# This makes deployment easier for users who prefer a single file

echo "📦 Creating combined k8s manifest..."

cat > k8s/all-in-one.yaml << 'EOF'
# ICAI INTROBBDD - Complete k3s Deployment Manifest
# Apply this file with: kubectl apply -f k8s/all-in-one.yaml

---
apiVersion: v1
kind: Namespace
metadata:
  name: introbbdd
  labels:
    name: introbbdd

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-data-pv
  namespace: introbbdd
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /opt/icai-mysql-data

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: workspace-pv
  namespace: introbbdd
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /opt/icai-workspace

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-data-pvc
  namespace: introbbdd
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: local-storage

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: workspace-pvc
  namespace: introbbdd
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: local-storage

---
EOF

# Add ConfigMap content from the separate file
cat k8s/mysql-configmap.yaml >> k8s/all-in-one.yaml

cat >> k8s/all-in-one.yaml << 'EOF'

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
  namespace: introbbdd
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: cochimbo/introbbddicade
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "comillas"
        - name: MYSQL_CHARSET
          value: "utf8mb4"
        - name: MYSQL_COLLATION
          value: "utf8mb4_general_ci"
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        - name: workspace
          mountPath: /workspace
        - name: mysql-init-scripts
          mountPath: /docker-entrypoint-initdb.d
          readOnly: true
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: mysql-data
        persistentVolumeClaim:
          claimName: mysql-data-pvc
      - name: workspace
        persistentVolumeClaim:
          claimName: workspace-pvc
      - name: mysql-init-scripts
        configMap:
          name: mysql-init-scripts

---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: introbbdd
  labels:
    app: mysql
spec:
  type: NodePort
  ports:
  - port: 3306
    targetPort: 3306
    nodePort: 30306
    protocol: TCP
  selector:
    app: mysql
EOF

echo "✅ Combined manifest created at k8s/all-in-one.yaml"
echo "🚀 You can now deploy with: kubectl apply -f k8s/all-in-one.yaml"