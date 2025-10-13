#!/bin/bash

# 🛑 Stop Load Test Script
# This script stops any running load tests

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
}

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                🛑 STOP LOAD TEST SCRIPT                     ║"
echo "║                                                              ║"
echo "║  Stops any running load tests                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Stop local processes
log "Checking for local load test processes..."
LOAD_PROCESSES=$(ps aux | grep -E "(load-test|hey|ab|stress)" | grep -v grep | grep -v "stop-load-test" || true)

if [ -n "$LOAD_PROCESSES" ]; then
    warning "Found local load test processes:"
    echo "$LOAD_PROCESSES"
    echo ""
    log "Killing local processes..."
    pkill -f "load-test" || true
    pkill -f "hey" || true
    pkill -f "ab" || true
    pkill -f "stress" || true
    success "Local processes stopped"
else
    success "No local load test processes found"
fi

# Stop Kubernetes pods
log "Checking for Kubernetes load test pods..."
LOAD_PODS=$(kubectl get pods --all-namespaces -o name | grep -E "(load|test|stress)" || true)

if [ -n "$LOAD_PODS" ]; then
    warning "Found Kubernetes load test pods:"
    echo "$LOAD_PODS"
    echo ""
    log "Deleting Kubernetes load test pods..."
    echo "$LOAD_PODS" | xargs kubectl delete
    success "Kubernetes load test pods deleted"
else
    success "No Kubernetes load test pods found"
fi

# Stop Kubernetes jobs
log "Checking for Kubernetes load test jobs..."
LOAD_JOBS=$(kubectl get jobs --all-namespaces -o name | grep -E "(load|test|stress)" || true)

if [ -n "$LOAD_JOBS" ]; then
    warning "Found Kubernetes load test jobs:"
    echo "$LOAD_JOBS"
    echo ""
    log "Deleting Kubernetes load test jobs..."
    echo "$LOAD_JOBS" | xargs kubectl delete
    success "Kubernetes load test jobs deleted"
else
    success "No Kubernetes load test jobs found"
fi

# Check HPA status
log "Checking HPA status..."
kubectl get hpa -n k8s-demo

# Final information
echo ""
echo "🛑 Load Test Stop Complete:"
echo "==========================="
echo ""
echo "✅ All load tests have been stopped"
echo ""
echo "📊 Current HPA Status:"
echo "======================"
kubectl get hpa -n k8s-demo
echo ""
echo "📋 Current Pod Status:"
echo "====================="
kubectl get pods -n k8s-demo
echo ""
echo "💡 The HPA will scale down the pods to minimum replicas"
echo "   as the load decreases."
echo ""

success "Load test stop complete! 🎉"
