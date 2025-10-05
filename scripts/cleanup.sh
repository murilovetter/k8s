#!/bin/bash

# 🧹 Cleanup Script - Kubernetes Infrastructure
# This script removes all created resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🧹 KUBERNETES CLEANUP                     ║"
echo "║                                                              ║"
echo "║  Removing all created resources                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Confirmation
echo -e "${YELLOW}⚠️  WARNING: This script will remove ALL resources from namespace k8s-demo${NC}"
echo -e "${YELLOW}   This includes:${NC}"
echo -e "${YELLOW}   - All applications (frontend, backend, mysql)${NC}"
echo -e "${YELLOW}   - All MySQL data${NC}"
echo -e "${YELLOW}   - All persistent volumes${NC}"
echo -e "${YELLOW}   - All secrets and configmaps${NC}"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# 1. Check if namespace exists
log "Checking namespace k8s-demo..."

if ! kubectl get namespace k8s-demo &> /dev/null; then
    warning "Namespace k8s-demo does not exist. Nothing to clean."
    exit 0
fi

success "Namespace k8s-demo found"

# 2. List resources before cleanup
log "Listing resources before cleanup..."

echo ""
echo "📊 Current Resources:"
echo "====================="
kubectl get all -n k8s-demo
echo ""

echo "💾 Volumes:"
echo "=========="
kubectl get pv,pvc -n k8s-demo
echo ""

echo "🔐 Secrets:"
echo "=========="
kubectl get secrets -n k8s-demo
echo ""

echo "⚙️  ConfigMaps:"
echo "============="
kubectl get configmaps -n k8s-demo
echo ""

# 3. Remove resources
log "Removing resources..."

# Remove deployments
log "Removing deployments..."
kubectl delete deployment --all -n k8s-demo 2>/dev/null || true

# Remove services
log "Removing services..."
kubectl delete service --all -n k8s-demo 2>/dev/null || true

# Remove ingress
log "Removing ingress..."
kubectl delete ingress --all -n k8s-demo 2>/dev/null || true

# Remove persistent volume claims
log "Removing PVCs..."
kubectl delete pvc --all -n k8s-demo 2>/dev/null || true

# Remove secrets
log "Removing secrets..."
kubectl delete secret --all -n k8s-demo 2>/dev/null || true

# Remove configmaps
log "Removing configmaps..."
kubectl delete configmap --all -n k8s-demo 2>/dev/null || true

# Remove persistent volumes
log "Removing PersistentVolumes..."
kubectl delete pv mysql-pv 2>/dev/null || true

# Remove storage class
log "Removing StorageClass..."
kubectl delete storageclass local-storage 2>/dev/null || true

success "Resources removed"

# 3.5. Wipe hostPath data on nodes (WSL/Docker Desktop fix)
log "Wiping hostPath data on nodes (if present) ..."

# Create a temporary DaemonSet that mounts host /tmp and removes /tmp/mysql-data
HOST_CLEANER_YAML="/tmp/host-cleaner.yaml"
cat > "$HOST_CLEANER_YAML" <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: host-cleaner
  namespace: k8s-demo
spec:
  selector:
    matchLabels:
      app: host-cleaner
  template:
    metadata:
      labels:
        app: host-cleaner
    spec:
      hostPID: true
      hostNetwork: true
      containers:
      - name: cleaner
        image: busybox:1.36
        securityContext:
          privileged: true
        command: ["/bin/sh","-c"]
        args:
          - |
            echo "Cleaning /tmp/mysql-data on host...";
            rm -rf /host-tmp/mysql-data || true;
            echo "Done";
            sleep 5;
        volumeMounts:
        - name: host-tmp
          mountPath: /host-tmp
      terminationGracePeriodSeconds: 0
      volumes:
      - name: host-tmp
        hostPath:
          path: /tmp
          type: Directory
EOF

# Apply DaemonSet and wait briefly
kubectl apply -f "$HOST_CLEANER_YAML" 1>/dev/null || true
kubectl rollout status ds/host-cleaner -n k8s-demo --timeout=60s 1>/dev/null || true

# Print logs (best-effort) then remove DaemonSet
kubectl logs -n k8s-demo ds/host-cleaner 2>/dev/null || true
kubectl delete ds host-cleaner -n k8s-demo --wait=true 1>/dev/null || true
rm -f "$HOST_CLEANER_YAML"

# 4. Wait for complete removal
log "Waiting for complete pod removal..."
kubectl wait --for=delete pod --all -n k8s-demo --timeout=60s 2>/dev/null || true

# 5. Remove namespace
log "Removing namespace k8s-demo..."
kubectl delete namespace k8s-demo

success "Namespace removed"

# 6. Check cleanup
log "Checking cleanup..."

echo ""
echo "📊 Status after cleanup:"
echo "======================="
kubectl get namespaces | grep k8s-demo || echo "Namespace k8s-demo does not exist"
echo ""

echo "💾 PersistentVolumes:"
echo "===================="
kubectl get pv | grep mysql-pv || echo "PersistentVolume mysql-pv does not exist"
echo ""

echo "📦 StorageClasses:"
echo "================="
kubectl get storageclass | grep local-storage || echo "StorageClass local-storage does not exist"
echo ""

# 7. Clean local data (optional)
log "Cleaning local data..."

# Remove MySQL data directory
if [ -d "/tmp/mysql-data" ]; then
    log "Removing directory /tmp/mysql-data..."
    rm -rf /tmp/mysql-data
    success "Data directory removed"
fi

# 8. Final information
echo ""
echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
echo ""
echo "📋 What was removed:"
echo "==================="
echo "✅ Namespace k8s-demo"
echo "✅ All applications (frontend, backend, mysql)"
echo "✅ All services and ingress"
echo "✅ All persistent volumes"
echo "✅ All secrets and configmaps"
echo "✅ MySQL data"
echo ""
echo "🔧 To recreate the infrastructure:"
echo "================================="
echo "1. Run: ./scripts/setup.sh"
echo "2. Run: ./scripts/deploy.sh"
echo ""

success "Cleanup completed! 🧹"
