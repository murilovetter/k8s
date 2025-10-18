#!/bin/bash

# 🧪 VPA Test Script
# This script tests VPA functionality with controlled experiments

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

# Function to check if VPA is installed
check_vpa() {
    if ! kubectl get vpa -n k8s-demo >/dev/null 2>&1; then
        print_error "VPA is not installed or configured"
        print_status "Please run ./scripts/setup-vpa.sh first"
        exit 1
    fi
    
    print_success "VPA is installed and configured"
}

# Function to show VPA status
show_vpa_status() {
    print_status "Current VPA status:"
    echo ""
    kubectl get vpa -n k8s-demo
    echo ""
    
    print_status "VPA recommendations:"
    echo ""
    kubectl describe vpa backend-vpa -n k8s-demo | grep -A 10 "Recommendation" || echo "No recommendations yet"
    echo ""
}

# Function to test VPA data collection
test_data_collection() {
    print_status "Testing VPA data collection..."
    echo ""
    
    # Show current resource usage
    print_status "Current resource usage:"
    kubectl top pods -n k8s-demo
    echo ""
    
    # Show VPA status
    show_vpa_status
    
    # Generate load
    print_status "Generating load for 5 minutes..."
    print_warning "This will run in the background. Press Ctrl+C to stop early."
    
    # Start load test in background
    ./scripts/load-test.sh 300 100 60 &
    LOAD_TEST_PID=$!
    
    # Monitor for 5 minutes
    for i in {1..5}; do
        sleep 60
        print_status "Minute $i/5 - Checking VPA status..."
        kubectl get vpa -n k8s-demo
        echo ""
    done
    
    # Stop load test
    kill $LOAD_TEST_PID 2>/dev/null || true
    ./scripts/stop-load-test.sh 2>/dev/null || true
    
    print_success "Load test completed"
    
    # Show final status
    show_vpa_status
}

# Function to test VPA mode transition
test_mode_transition() {
    print_status "Testing VPA mode transition..."
    echo ""
    
    # Show current mode
    CURRENT_MODE=$(kubectl get vpa backend-vpa -n k8s-demo -o jsonpath='{.spec.updatePolicy.updateMode}')
    print_status "Current VPA mode: $CURRENT_MODE"
    
    if [ "$CURRENT_MODE" = "Off" ]; then
        print_status "Switching to Initial mode..."
        kubectl patch vpa backend-vpa -n k8s-demo --type='merge' -p='{"spec":{"updatePolicy":{"updateMode":"Initial"}}}'
        print_success "VPA switched to Initial mode"
        
        print_status "Restarting deployment to apply recommendations..."
        kubectl rollout restart deployment/backend -n k8s-demo
        
        print_status "Waiting for rollout to complete..."
        kubectl rollout status deployment/backend -n k8s-demo
        
        print_success "Deployment restarted with VPA recommendations"
        
        # Show new resource allocation
        print_status "New resource allocation:"
        kubectl get pods -n k8s-demo -o wide
        echo ""
        
        # Show pod details
        print_status "Pod resource details:"
        kubectl describe pod $(kubectl get pods -n k8s-demo -l app=backend -o jsonpath='{.items[0].metadata.name}') -n k8s-demo | grep -A 10 "Requests:"
        echo ""
        
    else
        print_warning "VPA is already in $CURRENT_MODE mode"
    fi
}

# Function to test VPA vs HPA conflict
test_vpa_hpa_conflict() {
    print_status "Testing VPA vs HPA conflict..."
    echo ""
    
    # Check if HPA exists
    if kubectl get hpa -n k8s-demo >/dev/null 2>&1; then
        print_status "Current HPA status:"
        kubectl get hpa -n k8s-demo
        echo ""
        
        print_status "Current VPA status:"
        kubectl get vpa -n k8s-demo
        echo ""
        
        print_warning "VPA and HPA are both active - this may cause conflicts"
        print_status "Check events for conflicts:"
        kubectl get events -n k8s-demo --sort-by='.lastTimestamp' | tail -10
        echo ""
        
    else
        print_status "No HPA found - no conflict expected"
    fi
}

# Function to test hybrid strategy
test_hybrid_strategy() {
    print_status "Testing hybrid VPA + HPA strategy..."
    echo ""
    
    # Check if custom HPA exists
    if kubectl get hpa backend-hpa-custom -n k8s-demo >/dev/null 2>&1; then
        print_status "Custom HPA already exists"
    else
        print_status "Creating custom HPA..."
        kubectl apply -f k8s-manifests/autoscaling/vpa/backend-hpa-custom.yaml
        print_success "Custom HPA created"
    fi
    
    # Show both VPA and HPA
    print_status "VPA status:"
    kubectl get vpa -n k8s-demo
    echo ""
    
    print_status "HPA status:"
    kubectl get hpa -n k8s-demo
    echo ""
    
    print_success "Hybrid strategy is active"
}

# Function to show monitoring commands
show_monitoring() {
    print_status "VPA monitoring commands:"
    echo ""
    echo "  # Monitor VPA in real-time"
    echo "  kubectl get vpa -n k8s-demo -w"
    echo ""
    echo "  # Check VPA recommendations"
    echo "  kubectl describe vpa backend-vpa -n k8s-demo"
    echo ""
    echo "  # Check resource usage"
    echo "  kubectl top pods -n k8s-demo"
    echo ""
    echo "  # Check VPA events"
    echo "  kubectl get events -n k8s-demo --field-selector involvedObject.name=backend-vpa"
    echo ""
    echo "  # Check VPA logs"
    echo "  kubectl logs -n kube-system deployment/vpa-recommender"
    echo ""
}

# Function to show test results
show_results() {
    print_status "VPA test results:"
    echo ""
    
    # Show VPA status
    show_vpa_status
    
    # Show resource usage
    print_status "Current resource usage:"
    kubectl top pods -n k8s-demo
    echo ""
    
    # Show pod details
    print_status "Pod resource allocation:"
    kubectl get pods -n k8s-demo -o wide
    echo ""
    
    # Show events
    print_status "Recent VPA events:"
    kubectl get events -n k8s-demo --field-selector involvedObject.name=backend-vpa --sort-by='.lastTimestamp' | tail -5
    echo ""
}

# Main execution
main() {
    echo "🧪 VPA Test Script"
    echo "=================="
    echo ""
    
    # Check if VPA is installed
    check_vpa
    
    # Show current status
    show_vpa_status
    
    # Menu for test selection
    echo "Select test to run:"
    echo "1. Data collection test"
    echo "2. Mode transition test"
    echo "3. VPA vs HPA conflict test"
    echo "4. Hybrid strategy test"
    echo "5. Show monitoring commands"
    echo "6. Show test results"
    echo "7. Run all tests"
    echo ""
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            test_data_collection
            ;;
        2)
            test_mode_transition
            ;;
        3)
            test_vpa_hpa_conflict
            ;;
        4)
            test_hybrid_strategy
            ;;
        5)
            show_monitoring
            ;;
        6)
            show_results
            ;;
        7)
            test_data_collection
            test_mode_transition
            test_vpa_hpa_conflict
            test_hybrid_strategy
            show_results
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    print_success "VPA test completed!"
}

# Run main function
main "$@"
