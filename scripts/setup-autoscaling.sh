#!/bin/bash

# 🚀 Auto-scaling Setup Script
# This script sets up HPA and tests auto-scaling functionality

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
echo "║                    🚀 AUTO-SCALING SETUP                     ║"
echo "║                                                              ║"
echo "║  Setting up HPA and testing auto-scaling functionality       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuration
NAMESPACE="k8s-demo"

# Check prerequisites
log "Checking prerequisites..."

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    error "Namespace $NAMESPACE does not exist. Run ./scripts/setup.sh first."
fi

# Check if applications are deployed
if ! kubectl get deployment backend -n $NAMESPACE &> /dev/null; then
    error "Backend deployment not found. Run ./scripts/deploy.sh first."
fi

if ! kubectl get deployment frontend -n $NAMESPACE &> /dev/null; then
    error "Frontend deployment not found. Run ./scripts/deploy.sh first."
fi

# Check if Metrics Server is running
if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    error "Metrics Server not found. Run this script to install it."
fi

success "Prerequisites check passed"

# 1. Install Metrics Server (if not already installed)
log "Installing Metrics Server..."
kubectl apply -f k8s-manifests/autoscaling/metrics-server.yaml

# Wait for Metrics Server to be ready
log "Waiting for Metrics Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

success "Metrics Server installed and ready"

# 2. Verify Metrics Server is working
log "Verifying Metrics Server functionality..."
sleep 10  # Give it time to collect metrics

if kubectl top nodes &> /dev/null; then
    success "Metrics Server is collecting node metrics"
else
    warning "Metrics Server may not be fully ready yet"
fi

# 3. Apply HPA manifests
log "Applying HPA manifests..."

# Backend HPA
log "Creating Backend HPA..."
kubectl apply -f k8s-manifests/autoscaling/backend-hpa.yaml

# Frontend HPA
log "Creating Frontend HPA..."
kubectl apply -f k8s-manifests/autoscaling/frontend-hpa.yaml

success "HPA manifests applied"

# 4. Wait for HPA to be ready
log "Waiting for HPA to be ready..."
sleep 30

# 5. Show initial status
log "Initial HPA status:"
kubectl get hpa -n $NAMESPACE

# 6. Show current resource usage
log "Current resource usage:"
kubectl top pods -n $NAMESPACE --containers 2>/dev/null || warning "Resource metrics not available yet"

# 7. Show HPA details
log "HPA details:"
kubectl describe hpa -n $NAMESPACE

# 8. Test HPA functionality
log "Testing HPA functionality..."

# Check if we can get metrics
if kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/$NAMESPACE/pods &> /dev/null; then
    success "HPA can access pod metrics"
else
    warning "HPA may not be able to access pod metrics yet"
fi

# 9. Show scaling events
log "Recent scaling events:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i "scaled\|hpa" | tail -10

# 10. Final status
echo ""
echo "📊 Auto-scaling Setup Summary:"
echo "=============================="
echo "✅ Metrics Server: Installed and running"
echo "✅ Backend HPA: Configured (2-10 replicas, CPU: 70%, Memory: 80%)"
echo "✅ Frontend HPA: Configured (2-8 replicas, CPU: 60%, Memory: 70%)"
echo ""

# 11. Next steps
echo "🚀 Next Steps:"
echo "=============="
echo "1. Monitor HPA status:"
echo "   kubectl get hpa -n $NAMESPACE -w"
echo ""
echo "2. Run load test:"
echo "   ./scripts/load-test.sh [duration] [users] [ramp-up] [cpu]"
echo "   Example: ./scripts/load-test.sh 300 50 60 cpu"
echo ""
echo "3. Check scaling events:"
echo "   kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i scaled"
echo ""
echo "4. Monitor in Grafana:"
echo "   http://k8s-demo.local/grafana"
echo ""

success "Auto-scaling setup completed! 🎉"

# 12. Optional: Run a quick test
read -p "Do you want to run a quick 2-minute load test? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Running quick load test..."
    ./scripts/load-test.sh 120 20 30
fi
