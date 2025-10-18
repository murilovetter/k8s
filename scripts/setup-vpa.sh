#!/bin/bash

# 🎯 VPA Setup Script
# This script installs and configures VPA (Vertical Pod Autoscaler)

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if kubectl is configured
check_kubectl() {
    if ! command_exists kubectl; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "kubectl is not configured or cluster is not accessible"
        exit 1
    fi
    
    print_success "kubectl is configured and cluster is accessible"
}

# Function to check if namespace exists
check_namespace() {
    if ! kubectl get namespace k8s-demo >/dev/null 2>&1; then
        print_error "Namespace 'k8s-demo' does not exist"
        print_status "Please run ./scripts/setup.sh first"
        exit 1
    fi
    
    print_success "Namespace 'k8s-demo' exists"
}

# Function to install VPA
install_vpa() {
    print_status "Installing VPA components..."
    
    # Check if VPA is already installed
    if kubectl get pods -n kube-system | grep -q vpa; then
        print_warning "VPA components already installed"
        return 0
    fi
    
    # Clone VPA repository if not exists
    if [ ! -d "autoscaler" ]; then
        print_status "Cloning VPA repository..."
        git clone https://github.com/kubernetes/autoscaler.git
    fi
    
    # Install VPA
    cd autoscaler/vertical-pod-autoscaler/
    print_status "Running VPA installation script..."
    ./hack/vpa-install.sh
    
    # Wait for VPA components to be ready
    print_status "Waiting for VPA components to be ready..."
    kubectl wait --for=condition=ready pod -l app=vpa-recommender -n kube-system --timeout=300s
    kubectl wait --for=condition=ready pod -l app=vpa-updater -n kube-system --timeout=300s
    kubectl wait --for=condition=ready pod -l app=vpa-admission-controller -n kube-system --timeout=300s
    
    cd ../..
    print_success "VPA components installed successfully"
}

# Function to deploy VPA configurations
deploy_vpa_configs() {
    print_status "Deploying VPA configurations..."
    
    # Deploy VPA for backend
    kubectl apply -f k8s-manifests/autoscaling/vpa/backend-vpa.yaml
    print_success "Backend VPA configured"
    
    # Deploy VPA for frontend
    kubectl apply -f k8s-manifests/autoscaling/vpa/frontend-vpa.yaml
    print_success "Frontend VPA configured"
    
    # Deploy VPA monitoring
    kubectl apply -f k8s-manifests/autoscaling/vpa/vpa-monitoring.yaml
    print_success "VPA monitoring configured"
}

# Function to verify VPA installation
verify_vpa() {
    print_status "Verifying VPA installation..."
    
    # Check VPA components
    print_status "Checking VPA components..."
    kubectl get pods -n kube-system | grep vpa
    
    # Check VPA objects
    print_status "Checking VPA objects..."
    kubectl get vpa -n k8s-demo
    
    # Check VPA status
    print_status "Checking VPA status..."
    kubectl describe vpa backend-vpa -n k8s-demo | grep -A 5 "Status:"
    kubectl describe vpa frontend-vpa -n k8s-demo | grep -A 5 "Status:"
    
    print_success "VPA installation verified"
}

# Function to show VPA commands
show_commands() {
    print_status "Useful VPA commands:"
    echo ""
    echo "  # Check VPA status"
    echo "  kubectl get vpa -n k8s-demo"
    echo ""
    echo "  # Describe VPA recommendations"
    echo "  kubectl describe vpa backend-vpa -n k8s-demo"
    echo ""
    echo "  # Monitor VPA in real-time"
    echo "  kubectl get vpa -n k8s-demo -w"
    echo ""
    echo "  # Check VPA events"
    echo "  kubectl get events -n k8s-demo --field-selector involvedObject.name=backend-vpa"
    echo ""
    echo "  # Switch VPA to Initial mode"
    echo "  kubectl patch vpa backend-vpa -n k8s-demo --type='merge' -p='{\"spec\":{\"updatePolicy\":{\"updateMode\":\"Initial\"}}}'"
    echo ""
    echo "  # Check resource usage"
    echo "  kubectl top pods -n k8s-demo"
    echo ""
}

# Function to show next steps
show_next_steps() {
    print_status "Next steps:"
    echo ""
    echo "  1. Wait for VPA to collect data (24+ hours recommended)"
    echo "  2. Generate load to collect metrics:"
    echo "     ./scripts/load-test.sh 300 100 60"
    echo ""
    echo "  3. Check VPA recommendations:"
    echo "     kubectl describe vpa backend-vpa -n k8s-demo"
    echo ""
    echo "  4. When ready, switch to Initial mode:"
    echo "     kubectl patch vpa backend-vpa -n k8s-demo --type='merge' -p='{\"spec\":{\"updatePolicy\":{\"updateMode\":\"Initial\"}}}'"
    echo ""
    echo "  5. Restart deployment to apply recommendations:"
    echo "     kubectl rollout restart deployment/backend -n k8s-demo"
    echo ""
    echo "  6. Monitor the results:"
    echo "     kubectl get pods -n k8s-demo -o wide"
    echo ""
}

# Main execution
main() {
    echo "🎯 VPA Setup Script"
    echo "=================="
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_kubectl
    check_namespace
    
    # Install VPA
    install_vpa
    
    # Deploy VPA configurations
    deploy_vpa_configs
    
    # Verify installation
    verify_vpa
    
    # Show useful commands
    show_commands
    
    # Show next steps
    show_next_steps
    
    print_success "VPA setup completed successfully!"
    print_status "VPA is now running in 'Off' mode for data collection"
    print_warning "Remember: VPA and HPA cannot work together on CPU/memory metrics"
}

# Run main function
main "$@"
