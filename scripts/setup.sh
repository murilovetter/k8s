#!/bin/bash

# 🚀 Setup Script - Kubernetes Infrastructure
# This script configures the environment for application deployment

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
echo "║                    🚀 KUBERNETES SETUP                       ║"
echo "║                                                              ║"
echo "║  Configuring Kubernetes infrastructure for learning       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Check prerequisites
log "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Install Docker Desktop."
fi

if ! docker info &> /dev/null; then
    error "Docker is not running. Start Docker Desktop."
fi

success "Docker is working"

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    error "kubectl is not installed. Install kubectl."
fi

success "kubectl is installed"

# Check Kubernetes context
if ! kubectl config current-context &> /dev/null; then
    error "Kubernetes context not configured. Configure kubectl."
fi

CONTEXT=$(kubectl config current-context)
log "Current context: $CONTEXT"

if [[ "$CONTEXT" != "docker-desktop" ]]; then
    warning "Context is not docker-desktop. Make sure Docker Desktop has Kubernetes enabled."
fi

success "Kubernetes context configured"

# Check cluster
if ! kubectl get nodes &> /dev/null; then
    error "Could not connect to Kubernetes cluster."
fi

NODES=$(kubectl get nodes --no-headers | wc -l)
log "Kubernetes cluster working with $NODES node(s)"

success "Kubernetes cluster accessible"

# 2. Create namespace
log "Creating namespace k8s-demo..."

if kubectl get namespace k8s-demo &> /dev/null; then
    warning "Namespace k8s-demo already exists"
else
    kubectl create namespace k8s-demo
    success "Namespace k8s-demo created"
fi

# 3. Install Nginx Ingress Controller
log "Installing Nginx Ingress Controller..."

if kubectl get pods -n ingress-nginx &> /dev/null; then
    warning "Nginx Ingress Controller is already installed"
else
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
    
    # Wait for ingress controller to be ready
    log "Waiting for Nginx Ingress Controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    success "Nginx Ingress Controller installed"
fi

# 4. Check ingress controller
log "Checking Nginx Ingress Controller..."
kubectl get pods -n ingress-nginx

# 5. Create PersistentVolume for MySQL
log "Creating PersistentVolume for MySQL..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  namespace: k8s-demo
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /tmp/mysql-data
EOF

success "PersistentVolume created"

# 6. Create StorageClass
log "Creating StorageClass..."

cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

success "StorageClass created"

# 7. Check final status
log "Checking final status..."

echo ""
echo "📊 Cluster Status:"
echo "=================="
kubectl get nodes
echo ""

echo "📦 Namespaces:"
echo "=============="
kubectl get namespaces
echo ""

echo "🌐 Ingress Controller:"
echo "====================="
kubectl get pods -n ingress-nginx
echo ""

echo "💾 Storage:"
echo "=========="
kubectl get pv,pvc -n k8s-demo
echo ""

# 8. Next steps
echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo "📋 Next steps:"
echo "=============="
echo "1. Build Docker images:"
echo "   docker build -t k8s-demo/frontend:latest -f docker/Dockerfile.frontend ./apps/frontend"
echo "   docker build -t k8s-demo/backend:latest -f docker/Dockerfile.backend ./apps/backend"
echo ""
echo "2. Deploy application:"
echo "   ./scripts/deploy.sh"
echo ""
echo "3. Check status:"
echo "   kubectl get pods -n k8s-demo"
echo ""
echo "4. Access application:"
echo "   kubectl port-forward service/frontend 3000:80 -n k8s-demo"
echo "   Access: http://localhost:3000"
echo ""

success "Setup completed! 🚀"
