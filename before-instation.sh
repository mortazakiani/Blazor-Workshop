#!/bin/bash

# Create config directory
mkdir -p k8s-config

# Set permissions and ownership for config directory
chmod -R 777 k8s-config
chown -R nobody:nogroup k8s-config

# Create all hostPath directories and set their permissions
paths=(
    "/mnt/disks/disk1"
    "/mnt/disks/disk2"
    "/mnt/disks/disk3"
    "/mnt/disks/disk4"
    "/mnt/disks/disk5"
    "/mnt/disks/disk6"
    "/mnt/disks/disk7"
)

for path in "${paths[@]}"; do
    mkdir -p "$path"
    chmod 777 "$path"
    chown nobody:nogroup "$path"
done

# Write StorageClass configuration
cat << EOF > k8s-config/storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
EOF


kubectl  apply -f k8s-config/storageclass.yaml
# Write PersistentVolume List configuration
cat << EOF > k8s-config/pv-list.yaml
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-1
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk1"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-2
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk2"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-3
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk3"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-4
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk4"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-5
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk5"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-6
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk6"
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-7
    spec:
      capacity:
        storage: 8Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      hostPath:
        path: "/mnt/disks/disk7"
EOF
kubectl  apply -f k8s-config/pv-list.yaml
# Write Sentry values configuration as values.yaml
cat << EOF > k8s-config/values.yaml
# sentry-values.yaml
sentry:
  web:
    replicas: 1
  worker:
    replicas: 1
kafka:
  enabled: false
externalKafka:
  host: "kafka.default.svc.cluster.local"
  port: 9092

# PostgreSQL Configuration (for data-sentry-sentry-postgresql-0)
postgresql:
  enabled: true
  primary:
    persistence:
      enabled: true
      storageClass: "local-storage"
      size: 8Gi  # Set to 8Gi for data-sentry-sentry-postgresql-0

# ClickHouse and Zookeeper Configuration (for data-sentry-zookeeper-clickhouse-0)
clickhouse:
  enabled: true
  clickhouse:
    persistentVolumeClaim:
      enabled: true
      dataPersistentVolume:
        storage: 8Gi
        storageClassName: "local-storage"
zookeeper:
    enabled: true
    persistence:
      enabled: true
      storageClass: "local-storage"
      size: 8Gi  # Set to 8Gi for data-sentry-zookeeper-clickhouse-0

# Redis Configuration (for redis-data-sentry-sentry-redis-replicas)
redis:
  enabled: true
  architecture: replication
  master:
    persistence:
      enabled: true
      storageClass: "local-storage"
      size: 8Gi
  replica:
    persistence:
      enabled: true
      storageClass: "local-storage"
      size: 8Gi  # Set to 8Gi for redis-data-sentry-sentry-redis-replicas

rabbitmq:
  enabled: true
  persistence:
    enabled: true
    storageClass: "local-storage"
    size: 8Gi
  resources:
    limits:
      nofile: 65536  # Plain integer, no soft/hard nesting
    requests:
      nofile: 65536  # Plain integer
  containerSecurityContext:
    enabled: true
    capabilities:
      add: ["SYS_RESOURCE"]
# Sentry Filestore (optional, included for completeness)
filestore:
  type: filesystem
  filesystem:
    persistence:
      enabled: true
      storageClass: "local-storage"
      size: 8Gi
EOF

echo "Created all hostPath directories with 777 permissions and nobody:nogroup ownership"
echo "Configurations written to k8s-config/storageclass.yaml, k8s-config/pv-list.yaml, and k8s-config/values.yaml"