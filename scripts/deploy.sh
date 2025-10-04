#!/bin/bash

# 🚀 Deploy Script - Kubernetes Infrastructure
# This script performs the complete application deployment

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
echo "║                    🚀 KUBERNETES DEPLOY                      ║"
echo "║                                                              ║"
echo "║  Performing complete application deployment                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Check prerequisites
log "Checking prerequisites..."

# Check if namespace exists
if ! kubectl get namespace k8s-demo &> /dev/null; then
    error "Namespace k8s-demo does not exist. Run ./scripts/setup.sh first."
fi

# Check if ingress controller is running
if ! kubectl get pods -n ingress-nginx &> /dev/null; then
    error "Nginx Ingress Controller is not installed. Run ./scripts/setup.sh first."
fi

success "Prerequisites verified"

# 2. Deploy MySQL
log "Deploying MySQL..."

kubectl apply -f k8s-manifests/mysql/

# Wait for MySQL to be ready
log "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n k8s-demo --timeout=300s

success "MySQL deployed"

# 3. Deploy Backend
log "Deploying Backend..."

kubectl apply -f k8s-manifests/backend/

# Wait for Backend to be ready
log "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n k8s-demo --timeout=300s

success "Backend deployed"

# 4. Deploy Frontend
log "Deploying Frontend..."

kubectl apply -f k8s-manifests/frontend/

# Wait for Frontend to be ready
log "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n k8s-demo --timeout=300s

success "Frontend deployed"

# 5. Deploy Ingress
log "Deploying Ingress..."

kubectl apply -f k8s-manifests/ingress/

success "Ingress deployed"

# 6. Deploy Monitoring (optional)
if [ -d "k8s-manifests/monitoring" ]; then
    log "Deploying Monitoring..."
    
    kubectl apply -f k8s-manifests/monitoring/
    
    # Wait for monitoring to be ready
    log "Waiting for Monitoring to be ready..."
    kubectl wait --for=condition=ready pod -l app=prometheus -n k8s-demo --timeout=300s
    kubectl wait --for=condition=ready pod -l app=grafana -n k8s-demo --timeout=300s
    
    success "Monitoring deployed"
fi

# 7. Check status
log "Checking deployment status..."

echo ""
echo "📊 Pod Status:"
echo "=============="
kubectl get pods -n k8s-demo
echo ""

echo "🌐 Service Status:"
echo "================="
kubectl get services -n k8s-demo
echo ""

echo "🔗 Ingress Status:"
echo "================="
kubectl get ingress -n k8s-demo
echo ""

# 8. Check application health
log "Checking application health..."

# Check MySQL
if kubectl get pods -l app=mysql -n k8s-demo | grep -q Running; then
    success "MySQL is running"
else
    warning "MySQL is not running"
fi

# Check Backend
if kubectl get pods -l app=backend -n k8s-demo | grep -q Running; then
    success "Backend is running"
else
    warning "Backend is not running"
fi

# Check Frontend
if kubectl get pods -l app=frontend -n k8s-demo | grep -q Running; then
    success "Frontend is running"
else
    warning "Frontend is not running"
fi

# 9. Access information
echo ""
echo -e "${GREEN}🎉 Deploy completed successfully!${NC}"
echo ""
echo "📋 Access Information:"
echo "====================="
echo ""
echo "🔗 Access via Port Forward:"
echo "---------------------------"
echo "Frontend:  kubectl port-forward service/frontend 3000:80 -n k8s-demo"
echo "Backend:   kubectl port-forward service/backend 3001:3000 -n k8s-demo"
echo "MySQL:     kubectl port-forward service/mysql 3306:3306 -n k8s-demo"
echo ""
echo "🌐 Access via Ingress:"
echo "---------------------"
echo "1. Add to /etc/hosts:"
echo "   echo '127.0.0.1 k8s-demo.local' | sudo tee -a /etc/hosts"
echo ""
echo "2. Access: http://k8s-demo.local"
echo ""
echo "📊 Monitoring:"
echo "-------------"
echo "Prometheus: kubectl port-forward service/prometheus 9090:9090 -n k8s-demo"
echo "Grafana:    kubectl port-forward service/grafana 3000:3000 -n k8s-demo"
echo ""
echo "🔧 Useful Commands:"
echo "==================="
echo "View logs:   kubectl logs -f deployment/backend -n k8s-demo"
echo "Check status: kubectl get pods -n k8s-demo"
echo "Access pod:  kubectl exec -it <pod-name> -n k8s-demo -- /bin/bash"
echo ""

success "Deploy completed! 🚀"
