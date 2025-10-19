#!/bin/bash

# 🚀 Helm Setup Script
# This script sets up Helm repositories and dependencies

set -e

echo "🚀 Setting up Helm for k8s-demo project..."

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

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    print_error "Helm is not installed. Please install Helm first."
    echo "Installation instructions:"
    echo "  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

print_success "Helm is installed: $(helm version --short)"

# Add Helm repositories
print_status "Adding Helm repositories..."

helm repo add bitnami https://charts.bitnami.com/bitnami
print_success "Added bitnami repository"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
print_success "Added prometheus-community repository"

helm repo add grafana https://grafana.github.io/helm-charts
print_success "Added grafana repository"

# Update repositories
print_status "Updating Helm repositories..."
helm repo update
print_success "Repositories updated"

# Update dependencies
print_status "Updating chart dependencies..."
helm dependency update ./charts/k8s-demo
print_success "Dependencies updated"

# List repositories
print_status "Current Helm repositories:"
helm repo list

print_success "Helm setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Build Docker images: docker build -t k8s-demo/frontend:latest -f docker/Dockerfile.frontend ./apps/frontend"
echo "  2. Build Docker images: docker build -t k8s-demo/backend:latest -f docker/Dockerfile.backend ./apps/backend"
echo "  3. Deploy with Helm: ./scripts/helm-deploy.sh dev"
echo ""

