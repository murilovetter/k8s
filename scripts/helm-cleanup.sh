#!/bin/bash

# 🚀 Helm Cleanup Script
# This script removes the k8s-demo application using Helm

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
    echo "  all       - All environments"
    echo ""
    echo "Options:"
    echo "  --force    - Force deletion without confirmation"
    echo "  --help     - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 all --force"
    echo "  $0 prod"
}

# Default values
ENVIRONMENT=""
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod|all)
            ENVIRONMENT="$1"
            shift
            ;;
        --force)
            FORCE=true
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
    print_error "Helm is not installed"
    exit 1
fi

# Function to cleanup environment
cleanup_environment() {
    local env=$1
    local namespace="k8s-demo-${env}"
    local release="k8s-demo-${env}"
    
    print_status "Cleaning up $env environment..."
    print_status "Namespace: $namespace"
    print_status "Release: $release"
    
    # Check if release exists
    if ! helm list -n $namespace | grep -q "$release"; then
        print_warning "Release $release not found in namespace $namespace"
        return 0
    fi
    
    # Confirmation prompt
    if [[ "$FORCE" == false ]]; then
        echo ""
        print_warning "This will delete the following:"
        echo "  - Helm release: $release"
        echo "  - Namespace: $namespace"
        echo "  - All resources in the namespace"
        echo ""
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleanup cancelled"
            return 0
        fi
    fi
    
    # Uninstall Helm release
    print_status "Uninstalling Helm release: $release"
    helm uninstall $release -n $namespace
    
    # Delete namespace
    print_status "Deleting namespace: $namespace"
    kubectl delete namespace $namespace --ignore-not-found=true
    
    print_success "Environment $env cleaned up successfully!"
}

# Main cleanup logic
if [[ "$ENVIRONMENT" == "all" ]]; then
    print_status "Cleaning up all environments..."
    
    # Cleanup all environments
    for env in dev staging prod; do
        cleanup_environment $env
    done
    
    print_success "All environments cleaned up successfully!"
else
    cleanup_environment $ENVIRONMENT
fi

echo ""
echo "📋 Cleanup completed!"
echo "  - Helm releases uninstalled"
echo "  - Namespaces deleted"
echo "  - All resources removed"
echo ""
echo "To redeploy, use: ./scripts/helm-deploy.sh $ENVIRONMENT"

