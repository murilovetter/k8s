# 🚀 Deploy Guide - Kubernetes

This guide explains how to perform the complete deployment of the Kubernetes infrastructure.

## 📋 Prerequisites

### 1. Docker Desktop
```bash
# Check if Docker Desktop is running
docker --version
docker-compose --version

# Enable Kubernetes in Docker Desktop
# Settings > Kubernetes > Enable Kubernetes
```

### 2. kubectl
```bash
# Check if kubectl is installed
kubectl version --client

# Check context
kubectl config current-context
# Should return: docker-desktop
```

### 3. Check Cluster
```bash
# Check nodes
kubectl get nodes

# Check namespaces
kubectl get namespaces
```

## 🛠️ Initial Setup

### 1. Run Setup Script
```bash
# Give execution permission
chmod +x scripts/setup.sh

# Run setup
./scripts/setup.sh
```

The script will:
- Check prerequisites
- Create namespace `k8s-demo`
- Install Nginx Ingress Controller
- Configure Persistent Volumes

### 2. Build Docker Images
```bash
# Build frontend
docker build -t k8s-demo/frontend:latest -f docker/Dockerfile.frontend ./apps/frontend

# Build backend
docker build -t k8s-demo/backend:latest -f docker/Dockerfile.backend ./apps/backend
```

## 🚀 Application Deploy

### 1. Automatic Deploy
```bash
# Run deploy script
./scripts/deploy.sh
```

### 2. Manual Deploy (Step by Step)

#### 2.1. Namespace
```bash
kubectl apply -f k8s-manifests/namespace.yaml
```

#### 2.2. MySQL
```bash
# Deploy MySQL
kubectl apply -f k8s-manifests/mysql/

# Check status
kubectl get pods -n k8s-demo -l app=mysql
```

#### 2.3. Backend
```bash
# Deploy Backend
kubectl apply -f k8s-manifests/backend/

# Check status
kubectl get pods -n k8s-demo -l app=backend
```

#### 2.4. Frontend
```bash
# Deploy Frontend
kubectl apply -f k8s-manifests/frontend/

# Check status
kubectl get pods -n k8s-demo -l app=frontend
```

#### 2.5. Ingress
```bash
# Deploy Ingress
kubectl apply -f k8s-manifests/ingress/

# Check status
kubectl get ingress -n k8s-demo
```

## 🔍 Deploy Verification

### 1. Pod Status
```bash
# See all pods
kubectl get pods -n k8s-demo

# See pods with more details
kubectl get pods -n k8s-demo -o wide
```

### 2. Service Status
```bash
# See all services
kubectl get services -n k8s-demo

# See service details
kubectl describe service backend -n k8s-demo
```

### 3. Ingress Status
```bash
# See ingress
kubectl get ingress -n k8s-demo

# See details
kubectl describe ingress k8s-demo-ingress -n k8s-demo
```

### 4. Application Logs
```bash
# Backend logs
kubectl logs -f deployment/backend -n k8s-demo

# Frontend logs
kubectl logs -f deployment/frontend -n k8s-demo

# MySQL logs
kubectl logs -f deployment/mysql -n k8s-demo
```

## 🌐 Application Access

### 1. Via Port Forward (Development)
```bash
# Frontend
kubectl port-forward service/frontend 3000:80 -n k8s-demo
# Access: http://localhost:3000

# Backend
kubectl port-forward service/backend 3001:3000 -n k8s-demo
# Access: http://localhost:3001

# MySQL
kubectl port-forward service/mysql 3306:3306 -n k8s-demo
# Connect: localhost:3306
```

### 2. Via Ingress (Production)
```bash
# Add entry to /etc/hosts
echo "127.0.0.1 k8s-demo.local" | sudo tee -a /etc/hosts

# Access: http://k8s-demo.local
```

## 🔧 Troubleshooting

### 1. Pods not starting
```bash
# Check events
kubectl get events -n k8s-demo --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name> -n k8s-demo

# View logs
kubectl logs <pod-name> -n k8s-demo
```

### 2. Services not working
```bash
# Check endpoints
kubectl get endpoints -n k8s-demo

# Test connectivity
kubectl exec -it <pod-name> -n k8s-demo -- curl http://backend:3000/health
```

### 3. Ingress not working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress
kubectl describe ingress k8s-demo-ingress -n k8s-demo
```

## 🧹 Cleanup

### 1. Remove Application
```bash
# Run cleanup script
./scripts/cleanup.sh
```

### 2. Manual Cleanup
```bash
# Delete namespace (removes everything)
kubectl delete namespace k8s-demo

# Check if it was removed
kubectl get namespaces
```

## 📊 Monitoring

### 1. Prometheus
```bash
# Port forward to Prometheus
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo
# Access: http://localhost:9090
```

### 2. Grafana
```bash
# Port forward to Grafana
kubectl port-forward service/grafana 3000:3000 -n k8s-demo
# Access: http://localhost:3000
# Login: admin/admin
```

## 🎯 Next Steps

1. **Configure CI/CD** with GitHub Actions
2. **Implement robust Health Checks**
3. **Add TLS/SSL** for production
4. **Configure MySQL Backup**
5. **Implement Auto-scaling** with HPA
