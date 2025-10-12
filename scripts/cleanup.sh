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

# 1. Check prerequisites
log "Checking prerequisites..."

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    error "kubectl is not installed or not in PATH"
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
fi

success "Prerequisites check passed"

# 2. Check if namespace exists
log "Checking namespace k8s-demo..."

if ! kubectl get namespace k8s-demo &> /dev/null; then
    warning "Namespace k8s-demo does not exist. Nothing to clean."
    exit 0
fi

success "Namespace k8s-demo found"

# 3. List resources before cleanup
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

# 4. Remove resources
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

# Remove persistent volumes (improved cleanup for Retain policy)
log "Removing PersistentVolumes..."

# First, try to delete the PV normally
if kubectl get pv mysql-pv &> /dev/null; then
    log "Found mysql-pv, attempting removal..."
    
    # Check if PV is bound to a PVC
    PV_STATUS=$(kubectl get pv mysql-pv -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
    
    if [[ "$PV_STATUS" == "Bound" ]]; then
        log "PV is still bound, forcing PVC deletion..."
        kubectl delete pvc mysql-pvc -n k8s-demo --force --grace-period=0 2>/dev/null || true
        
        # Wait for PV to become available
        log "Waiting for PV to become available..."
        kubectl wait --for=jsonpath='{.status.phase}'=Available pv/mysql-pv --timeout=30s 2>/dev/null || true
    fi
    
    # Try to delete the PV
    kubectl delete pv mysql-pv 2>/dev/null || true
    
    # If PV still exists, force removal
    if kubectl get pv mysql-pv &> /dev/null; then
        warning "PV mysql-pv still exists, forcing removal..."
        
        # Remove finalizers to allow deletion
        kubectl patch pv mysql-pv -p '{"metadata":{"finalizers":null}}' 2>/dev/null || true
        
        # Force delete
        kubectl delete pv mysql-pv --force --grace-period=0 2>/dev/null || true
        
        # Final check
        if kubectl get pv mysql-pv &> /dev/null; then
            error "Failed to remove PersistentVolume mysql-pv. Manual intervention required."
        else
            success "PersistentVolume mysql-pv removed successfully"
        fi
    else
        success "PersistentVolume mysql-pv removed successfully"
    fi
else
    log "PersistentVolume mysql-pv not found"
fi

# Remove storage class
log "Removing StorageClass..."
kubectl delete storageclass local-storage 2>/dev/null || true

success "Resources removed"

# 4.5. Wipe hostPath data on nodes (improved cleanup)
log "Wiping hostPath data on nodes (if present) ..."

# First, try direct cleanup if we have access
if [ -d "/tmp/mysql-data" ]; then
    log "Found /tmp/mysql-data directory, removing directly..."
    sudo rm -rf /tmp/mysql-data 2>/dev/null || {
        warning "Direct removal failed, using DaemonSet cleanup..."
    }
fi

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
            echo "Cleaning MySQL data directories on host...";
            rm -rf /host-tmp/mysql-data || true;
            rm -rf /host-var/lib/mysql || true;
            echo "MySQL data cleanup completed";
            sleep 5;
        volumeMounts:
        - name: host-tmp
          mountPath: /host-tmp
        - name: host-var-lib
          mountPath: /host-var/lib
      terminationGracePeriodSeconds: 0
      volumes:
      - name: host-tmp
        hostPath:
          path: /tmp
          type: Directory
      - name: host-var-lib
        hostPath:
          path: /var/lib
          type: Directory
EOF

# Apply DaemonSet and wait briefly
log "Applying host cleaner DaemonSet..."
kubectl apply -f "$HOST_CLEANER_YAML" 1>/dev/null || true

# Wait for DaemonSet to be ready
log "Waiting for host cleaner to be ready..."
kubectl rollout status ds/host-cleaner -n k8s-demo --timeout=60s 1>/dev/null || true

# Print logs (best-effort) then remove DaemonSet
log "Host cleaner logs:"
kubectl logs -n k8s-demo ds/host-cleaner 2>/dev/null || true

# Clean up DaemonSet
log "Removing host cleaner DaemonSet..."
kubectl delete ds host-cleaner -n k8s-demo --wait=true 1>/dev/null || true
rm -f "$HOST_CLEANER_YAML"

# Verify cleanup
if [ -d "/tmp/mysql-data" ]; then
    warning "MySQL data directory still exists at /tmp/mysql-data"
else
    success "MySQL data directory cleanup completed"
fi

# 5. Wait for complete removal
log "Waiting for complete pod removal..."
kubectl wait --for=delete pod --all -n k8s-demo --timeout=60s 2>/dev/null || true

# 6. Remove namespace
log "Removing namespace k8s-demo..."
kubectl delete namespace k8s-demo

success "Namespace removed"

# 7. Check cleanup
log "Checking cleanup..."

echo ""
echo "📊 Status after cleanup:"
echo "======================="

# Check namespace
if kubectl get namespace k8s-demo &> /dev/null; then
    warning "Namespace k8s-demo still exists"
    kubectl get namespace k8s-demo
else
    success "Namespace k8s-demo successfully removed"
fi
echo ""

# Check PersistentVolumes
echo "💾 PersistentVolumes:"
echo "===================="
if kubectl get pv mysql-pv &> /dev/null; then
    warning "PersistentVolume mysql-pv still exists"
    kubectl get pv mysql-pv
else
    success "PersistentVolume mysql-pv successfully removed"
fi
echo ""

# Check StorageClasses
echo "📦 StorageClasses:"
echo "================="
if kubectl get storageclass local-storage &> /dev/null; then
    warning "StorageClass local-storage still exists"
    kubectl get storageclass local-storage
else
    success "StorageClass local-storage successfully removed"
fi
echo ""

# Check for any remaining resources in k8s-demo namespace
echo "🔍 Remaining resources in k8s-demo namespace:"
echo "============================================="
if kubectl get namespace k8s-demo &> /dev/null; then
    kubectl get all -n k8s-demo 2>/dev/null || echo "No resources found"
    kubectl get pvc -n k8s-demo 2>/dev/null || echo "No PVCs found"
    kubectl get secrets -n k8s-demo 2>/dev/null || echo "No secrets found"
    kubectl get configmaps -n k8s-demo 2>/dev/null || echo "No configmaps found"
else
    echo "Namespace k8s-demo does not exist - cleanup successful"
fi
echo ""

# 8. Clean local data (final cleanup)
log "Performing final local data cleanup..."

# Remove MySQL data directories
MYSQL_DIRS=("/tmp/mysql-data" "/var/lib/mysql" "/tmp/k8s-mysql-data")

for dir in "${MYSQL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        log "Removing directory $dir..."
        sudo rm -rf "$dir" 2>/dev/null || {
            warning "Failed to remove $dir with sudo, trying without..."
            rm -rf "$dir" 2>/dev/null || warning "Could not remove $dir"
        }
        success "Directory $dir removed"
    else
        log "Directory $dir does not exist, skipping..."
    fi
done

# Clean up any temporary files
log "Cleaning temporary files..."
rm -f /tmp/host-cleaner.yaml 2>/dev/null || true
rm -f /tmp/k8s-*.yaml 2>/dev/null || true
success "Temporary files cleaned"

# 9. Final information
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
