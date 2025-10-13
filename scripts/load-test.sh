#!/bin/bash

# 🚀 Load Testing Script - Kubernetes Auto-scaling
# This script generates load to test HPA functionality

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
echo "║                    🚀 LOAD TESTING SCRIPT                    ║"
echo "║                                                              ║"
echo "║  Testing HPA auto-scaling with resource-based metrics        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuration
NAMESPACE="k8s-demo"
BACKEND_SERVICE="backend"
FRONTEND_SERVICE="frontend"
TEST_DURATION=${1:-300}  # Default 5 minutes
CONCURRENT_USERS=${2:-50}  # Default 50 concurrent users
RAMP_UP_TIME=${3:-60}    # Default 1 minute ramp-up

# Check prerequisites
log "Checking prerequisites..."

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    error "Namespace $NAMESPACE does not exist. Deploy the application first."
fi

# Check if services exist
if ! kubectl get service $BACKEND_SERVICE -n $NAMESPACE &> /dev/null; then
    error "Backend service not found. Deploy the application first."
fi

if ! kubectl get service $FRONTEND_SERVICE -n $NAMESPACE &> /dev/null; then
    error "Frontend service not found. Deploy the application first."
fi

# Check if HPA exists
if ! kubectl get hpa backend-hpa -n $NAMESPACE &> /dev/null; then
    warning "Backend HPA not found. Deploy HPA manifests first."
fi

success "Prerequisites check passed"

# Get service URLs
log "Getting service URLs..."
BACKEND_URL=$(kubectl get service $BACKEND_SERVICE -n $NAMESPACE -o jsonpath='{.spec.clusterIP}'):3000
FRONTEND_URL=$(kubectl get service $FRONTEND_SERVICE -n $NAMESPACE -o jsonpath='{.spec.clusterIP}'):80

log "Backend URL: $BACKEND_URL"
log "Frontend URL: $FRONTEND_URL"

# Function to generate CPU load
generate_cpu_load() {
    local duration=$1
    local intensity=$2
    
    log "Generating CPU load for $duration seconds with intensity $intensity..."
    
    # Delete existing pod if it exists
    kubectl delete pod cpu-load-generator -n $NAMESPACE 2>/dev/null || true
    sleep 2
    
    # Create a temporary pod that generates CPU load
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cpu-load-generator
  namespace: $NAMESPACE
spec:
  containers:
  - name: cpu-load
    image: busybox:1.36
    command: ["/bin/sh"]
    args:
      - -c
      - |
        echo "Starting CPU load generation..."
        for i in \$(seq 1 $intensity); do
          while true; do
            echo "CPU load process \$i running..."
            sleep 0.1
          done &
        done
        sleep $duration
        echo "CPU load generation completed"
        killall sh
  restartPolicy: Never
EOF
}

# Function to generate HTTP load
generate_http_load() {
    local duration=$1
    local concurrent_users=$2
    
    log "Generating HTTP load for $duration seconds with $concurrent_users concurrent users..."
    
    # Delete existing pod if it exists
    kubectl delete pod http-load-generator -n $NAMESPACE 2>/dev/null || true
    sleep 2
    
    # Create a temporary pod that generates HTTP load
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: http-load-generator
  namespace: $NAMESPACE
spec:
  containers:
  - name: http-load
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args:
      - -c
      - |
        echo "Starting HTTP load generation..."
        for i in \$(seq 1 $concurrent_users); do
          while true; do
            curl -s http://$BACKEND_URL/health > /dev/null
            curl -s http://$BACKEND_URL/api/tasks > /dev/null
            curl -s http://$FRONTEND_URL/ > /dev/null
            sleep 0.5
          done &
        done
        sleep $duration
        echo "HTTP load generation completed"
        killall curl
  restartPolicy: Never
EOF
}

# Function to monitor HPA status
monitor_hpa() {
    local duration=$1
    local interval=10
    
    log "Monitoring HPA status for $duration seconds (interval: ${interval}s)..."
    
    local end_time=$(($(date +%s) + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        echo ""
        echo "📊 HPA Status - $(date)"
        echo "========================"
        
        # Backend HPA
        if kubectl get hpa backend-hpa -n $NAMESPACE &> /dev/null; then
            echo "Backend HPA:"
            kubectl get hpa backend-hpa -n $NAMESPACE
        fi
        
        # Frontend HPA
        if kubectl get hpa frontend-hpa -n $NAMESPACE &> /dev/null; then
            echo "Frontend HPA:"
            kubectl get hpa frontend-hpa -n $NAMESPACE
        fi
        
        # Pod status
        echo ""
        echo "Pod Status:"
        kubectl get pods -n $NAMESPACE -l app=backend
        kubectl get pods -n $NAMESPACE -l app=frontend
        
        # Resource usage
        echo ""
        echo "Resource Usage:"
        kubectl top pods -n $NAMESPACE --containers
        
        sleep $interval
    done
}

# Function to clean up load generators
cleanup_load_generators() {
    log "Cleaning up load generators..."
    kubectl delete pod cpu-load-generator -n $NAMESPACE 2>/dev/null || true
    kubectl delete pod http-load-generator -n $NAMESPACE 2>/dev/null || true
    success "Load generators cleaned up"
}

# Trap to ensure cleanup on exit
trap cleanup_load_generators EXIT

# Main execution
log "Starting load test..."
log "Test duration: $TEST_DURATION seconds"
log "Concurrent users: $CONCURRENT_USERS"
log "Ramp-up time: $RAMP_UP_TIME seconds"

# Show initial status
log "Initial HPA and pod status:"
kubectl get hpa -n $NAMESPACE
kubectl get pods -n $NAMESPACE

# Start monitoring in background
monitor_hpa $TEST_DURATION &
MONITOR_PID=$!

# Phase 1: Ramp-up (gradual increase)
log "Phase 1: Ramp-up period ($RAMP_UP_TIME seconds)"
generate_http_load $RAMP_UP_TIME $((CONCURRENT_USERS / 2))

# Phase 2: Peak load
log "Phase 2: Peak load period ($((TEST_DURATION - RAMP_UP_TIME)) seconds)"
generate_http_load $((TEST_DURATION - RAMP_UP_TIME)) $CONCURRENT_USERS

# Phase 3: CPU stress test (optional)
if [ "$4" = "cpu" ]; then
    log "Phase 3: CPU stress test (60 seconds)"
    generate_cpu_load 60 10
fi

# Wait for monitoring to complete
wait $MONITOR_PID

# Final status
log "Final HPA and pod status:"
kubectl get hpa -n $NAMESPACE
kubectl get pods -n $NAMESPACE

# Show scaling events
log "Scaling events:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i "scaled\|hpa"

success "Load test completed!"

# Summary
echo ""
echo "📋 Load Test Summary:"
echo "===================="
echo "✅ Test duration: $TEST_DURATION seconds"
echo "✅ Concurrent users: $CONCURRENT_USERS"
echo "✅ Ramp-up time: $RAMP_UP_TIME seconds"
echo ""
echo "🔧 Next steps:"
echo "1. Check HPA metrics: kubectl describe hpa -n $NAMESPACE"
echo "2. View pod logs: kubectl logs -f deployment/backend -n $NAMESPACE"
echo "3. Monitor in Grafana: http://k8s-demo.local/grafana"
echo ""
