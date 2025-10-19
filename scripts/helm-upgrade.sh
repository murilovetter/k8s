#!/bin/bash

# 🚀 Helm Upgrade Script
# This script upgrades the k8s-demo application using Helm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <environment> [options]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Options:"
    echo "  --dry-run    - Show what would be upgraded without actually upgrading"
    echo "  --debug      - Enable debug output"
    echo "  --help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 staging --dry-run"
    echo "  $0 prod --debug"
}

# Default values
ENVIRONMENT=""
DRY_RUN=false
DEBUG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if environment is provided
if [[ -z "$ENVIRONMENT" ]]; then
    print_error "Environment is required"
    show_usage
    exit 1
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    print_error "Helm is not installed. Please run ./scripts/helm-setup.sh first"
    exit 1
fi

# Check if values file exists
VALUES_FILE="values-${ENVIRONMENT}.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
    print_error "Values file not found: $VALUES_FILE"
    exit 1
fi

# Get namespace from values file
NAMESPACE=$(grep "namespace:" "$VALUES_FILE" | head -1 | sed 's/.*: *//' | tr -d ' ')
if [[ -z "$NAMESPACE" ]]; then
    NAMESPACE="k8s-demo-${ENVIRONMENT}"
fi

print_status "Upgrading k8s-demo in $ENVIRONMENT environment"
print_status "Namespace: $NAMESPACE"
print_status "Values file: $VALUES_FILE"

# Check if release exists
if ! helm list -n $NAMESPACE | grep -q "k8s-demo-${ENVIRONMENT}"; then
    print_error "Release k8s-demo-${ENVIRONMENT} not found in namespace $NAMESPACE"
    print_status "Use ./scripts/helm-deploy.sh $ENVIRONMENT to deploy first"
    exit 1
fi

# Build Docker images if not in dry-run mode
if [[ "$DRY_RUN" == false ]]; then
    print_status "Building Docker images..."
    
    # Build frontend
    print_status "Building frontend image..."
    docker build -t k8s-demo/frontend:latest -f docker/Dockerfile.frontend .
    
    # Build backend
    print_status "Building backend image..."
    docker build -t k8s-demo/backend:latest -f docker/Dockerfile.backend .
    
    print_success "Docker images built successfully"
fi

# Prepare Helm command
HELM_CMD="helm upgrade k8s-demo-${ENVIRONMENT} ./charts/k8s-demo -f $VALUES_FILE --namespace $NAMESPACE"

if [[ "$DRY_RUN" == true ]]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
    print_status "Running in dry-run mode..."
fi

if [[ "$DEBUG" == true ]]; then
    HELM_CMD="$HELM_CMD --debug"
fi

# Execute Helm command
print_status "Executing: $HELM_CMD"
eval $HELM_CMD

if [[ "$DRY_RUN" == false ]]; then
    print_success "Upgrade completed successfully!"
    echo ""
    echo "📋 Useful commands:"
    echo "  Check pods: kubectl get pods -n $NAMESPACE"
    echo "  Check services: kubectl get services -n $NAMESPACE"
    echo "  Check ingress: kubectl get ingress -n $NAMESPACE"
    echo "  Check HPA: kubectl get hpa -n $NAMESPACE"
    echo "  Helm status: helm status k8s-demo-${ENVIRONMENT} -n $NAMESPACE"
    echo "  Helm history: helm history k8s-demo-${ENVIRONMENT} -n $NAMESPACE"
    echo ""
    
    # Wait for pods to be ready
    print_status "Waiting for pods to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=k8s-demo -n $NAMESPACE --timeout=300s
    
    print_success "All pods are ready!"
else
    print_success "Dry-run completed successfully!"
fi
