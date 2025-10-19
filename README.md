# 🚀 Kubernetes Infrastructure - Complete Learning

This project demonstrates a complete Kubernetes infrastructure with frontend, backend applications and MariaDB database, including monitoring, auto-scaling, and multi-environment deployment using Helm charts.

## 📋 Overview

### 🎓 Learning with Cursor AI
This project is part of my Kubernetes learning journey, developed with the assistance of **Cursor AI** for:
- Code generation and optimization
- Kubernetes manifest creation and debugging
- Script automation and best practices
- Troubleshooting and problem-solving
- Documentation and explanations

Cursor has been instrumental in accelerating my understanding of Kubernetes concepts, HPA (Horizontal Pod Autoscaler), monitoring with Prometheus/Grafana, and infrastructure automation.

### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                DOCKER DESKTOP + KUBERNETES + HELM          │
├─────────────────────────────────────────────────────────────┤
│  Frontend (React)     │  Backend (Node.js)  │  MariaDB     │
│  - Nginx Ingress      │  - API REST         │  - Database  │
│  - Service            │  - Service          │  - Service   │
│  - Deployment         │  - Deployment       │  - StatefulSet│
│  - HPA                │  - HPA              │  - PVC       │
├─────────────────────────────────────────────────────────────┤
│  Monitoring: Prometheus + Grafana (with subpath support)   │
│  Storage: Persistent Volumes (Docker Desktop)              │
│  Ingress: Nginx Ingress Controller                          │
│  Deployment: Helm Charts (Multi-environment)               │
└─────────────────────────────────────────────────────────────┘
```

### Components
- **Frontend**: React + Nginx (with dynamic configuration)
- **Backend**: Node.js + Express + MariaDB2
- **Database**: MariaDB (Bitnami Helm Chart)
- **Monitoring**: Prometheus + Grafana (with subpath support)
- **Ingress**: Nginx Ingress Controller
- **Storage**: Persistent Volumes
- **Deployment**: Helm Charts with multi-environment support
- **Auto-scaling**: HPA (Horizontal Pod Autoscaler)

## 🛠️ Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl installed and configured
- Helm 3.x installed
- Node.js 18+ (for local development)
- Git

## 🚀 Quick Start

### Using Helm (Recommended)

```bash
# 1. Clone the repository
git clone <your-repository>
cd k8s

# 2. Setup Helm dependencies
./scripts/helm-setup.sh

# 3. Deploy development environment
./scripts/helm-deploy.sh dev

# 4. Deploy staging environment (optional)
./scripts/helm-deploy.sh staging

# 5. Check status
kubectl get pods -n k8s-demo-dev
kubectl get pods -n k8s-demo-staging
```

### Using Traditional Kubernetes Manifests

```bash
# 1. Clone the repository
git clone <your-repository>
cd k8s

# 2. Run setup
./scripts/setup.sh

# 3. Deploy the application
./scripts/deploy.sh

# 4. Setup auto-scaling (optional)
./scripts/setup-autoscaling.sh

# 5. Check status
kubectl get pods -n k8s-demo
```

## 📁 Project Structure

```
k8s/
├── apps/                    # Applications
│   ├── frontend/           # React + Nginx
│   ├── backend/            # Node.js + Express
│   └── database/           # MariaDB
├── charts/                  # Helm Charts
│   └── k8s-demo/           # Main application chart
│       ├── Chart.yaml      # Chart metadata
│       ├── values.yaml     # Default values
│       └── templates/      # Kubernetes templates
│           ├── _helpers.tpl # Helper templates
│           ├── backend/    # Backend resources
│           ├── frontend/   # Frontend resources
│           ├── ingress/    # Ingress configuration
│           └── autoscaling/ # HPA templates
├── k8s-manifests/          # Traditional Kubernetes Manifests
│   ├── namespace.yaml
│   ├── mysql/
│   ├── backend/
│   ├── frontend/
│   ├── ingress/
│   ├── monitoring/
│   └── autoscaling/        # HPA, VPA and Metrics Server
├── docker/                 # Dockerfiles
│   ├── Dockerfile.frontend
│   ├── Dockerfile.backend
│   ├── nginx-template.conf # Dynamic Nginx config
│   └── start-nginx.sh      # Nginx startup script
├── scripts/                # Automation Scripts
│   ├── helm-setup.sh       # Helm dependencies setup
│   ├── helm-deploy.sh      # Helm deployment
│   ├── helm-upgrade.sh     # Helm upgrade
│   ├── helm-cleanup.sh     # Helm cleanup
│   ├── setup.sh            # Traditional setup
│   ├── deploy.sh           # Traditional deploy
│   ├── cleanup.sh          # Traditional cleanup
│   ├── setup-autoscaling.sh
│   ├── setup-vpa.sh
│   ├── test-vpa.sh
│   ├── load-test.sh
│   └── setup-grafana-hpa-dashboard.sh
├── values-dev.yaml         # Development environment values
├── values-staging.yaml     # Staging environment values
└── docs/                   # Documentation
    ├── DEPLOY.md
    ├── MONITORING.md
    ├── TROUBLESHOOTING.md
    ├── VPA-EXPERIMENT.md
    └── HELM.md             # Helm deployment guide
```

## 📚 Documentation

- [Helm Deployment Guide](docs/HELM.md) - **New!**
- [Deploy Guide](docs/DEPLOY.md)
- [Monitoring](docs/MONITORING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [VPA Experiment](docs/VPA-EXPERIMENT.md)

## 🔧 Troubleshooting

### Grafana Prometheus Connection Issues

If you see "404 Not Found" when configuring Prometheus data source in Grafana:

**Problem**: Grafana tries to access `http://prometheus:9090` but Prometheus is exposed via Ingress.

**Solution**: Use the correct URL in Grafana data source configuration:
- **URL**: `http://k8s-demo.local/prometheus`
- **Access**: Server (default)
- **Skip TLS Verify**: Enabled

**Quick Fix**:
```bash
./scripts/fix-grafana-prometheus-datasource.sh
```

## 🎯 Helm Deployment

This project now supports **Helm-based deployment** with multi-environment support, making it easier to manage different environments (dev, staging, production) with consistent configurations.

### 🌍 Multi-Environment Support

#### Development Environment
```bash
# Deploy development environment
./scripts/helm-deploy.sh dev

# Access URLs:
# - Frontend: http://k8s-demo.local
# - API: http://k8s-demo.local/api/users
# - Prometheus: http://k8s-demo.local/prometheus/
# - Grafana: http://k8s-demo.local/grafana/ (admin/dev-admin)
```

#### Staging Environment
```bash
# Deploy staging environment
./scripts/helm-deploy.sh staging

# Access URLs:
# - Frontend: http://k8s-demo-staging.local
# - API: http://k8s-demo-staging.local/api/users
# - Prometheus: http://k8s-demo-staging.local/prometheus/
# - Grafana: http://k8s-demo-staging.local/grafana/ (admin/staging-admin)
```

### 🔧 Helm Chart Features

- **Dynamic Configuration**: Environment-specific values files
- **Helper Templates**: Reusable template functions for ingress paths
- **Dependency Management**: MariaDB, Prometheus, and Grafana as Helm dependencies
- **Auto-scaling**: Built-in HPA templates for frontend and backend
- **Subpath Support**: Prometheus and Grafana configured for subpath access
- **Environment Variables**: Dynamic backend service discovery for frontend

### 📋 Environment Configuration

Each environment has its own values file:
- `values-dev.yaml` - Development environment overrides
- `values-staging.yaml` - Staging environment overrides
- `charts/k8s-demo/values.yaml` - Default values for all environments

### 🚀 Helm Commands

```bash
# Setup Helm dependencies
./scripts/helm-setup.sh

# Deploy specific environment
./scripts/helm-deploy.sh <environment>

# Upgrade existing deployment
./scripts/helm-upgrade.sh <environment>

# Clean up environment
./scripts/helm-cleanup.sh <environment>

# List all deployments
helm list --all-namespaces
```

## 🚀 Auto-scaling Features

This project includes comprehensive auto-scaling capabilities using both Kubernetes HPA (Horizontal Pod Autoscaler) and VPA (Vertical Pod Autoscaler).

### 🎯 Auto-scaling Configuration

#### Backend HPA
- **Min Replicas**: 2
- **Max Replicas**: 10
- **CPU Target**: 70% utilization
- **Memory Target**: 80% utilization
- **Scale Up**: 50% increase or 4 pods per minute
- **Scale Down**: 10% decrease or 2 pods per minute

#### Frontend HPA
- **Min Replicas**: 2
- **Max Replicas**: 8
- **CPU Target**: 60% utilization
- **Memory Target**: 70% utilization
- **Scale Up**: 50% increase or 2 pods per minute
- **Scale Down**: 10% decrease or 1 pod per minute

### 🎯 VPA (Vertical Pod Autoscaler) Configuration

#### Backend VPA
- **Update Mode**: Off (data collection) → Initial (apply recommendations)
- **CPU Range**: 50m - 1 core
- **Memory Range**: 128Mi - 2Gi
- **Controlled Resources**: CPU and Memory
- **Controlled Values**: Requests and Limits

#### Frontend VPA
- **Update Mode**: Off (data collection) → Initial (apply recommendations)
- **CPU Range**: 25m - 500m
- **Memory Range**: 64Mi - 1Gi
- **Controlled Resources**: CPU and Memory
- **Controlled Values**: Requests and Limits

#### VPA Modes
- **Off**: Only collects data and generates recommendations
- **Initial**: Applies recommendations to new pods only
- **Auto**: Automatically applies recommendations (⚠️ can cause downtime)

### 🧪 Load Testing

The project includes comprehensive load testing capabilities:

```bash
# Basic load test (5 minutes, 50 users, 1 minute ramp-up)
./scripts/load-test.sh

# Custom load test
./scripts/load-test.sh 300 100 60 cpu

# Parameters:
# - Duration (seconds): How long to run the test
# - Concurrent users: Number of simultaneous users
# - Ramp-up time: Time to gradually increase load
# - CPU stress: Optional CPU stress test
```

### 📊 Monitoring

#### Grafana Dashboard
- **HPA Status Overview**: Current vs desired replicas
- **CPU/Memory Utilization**: Real-time resource usage vs targets
- **Scaling Events**: Historical scaling up/down events
- **Pod Replicas Timeline**: Visual representation of scaling

#### Metrics Available
- `kube_horizontalpodautoscaler_status_current_replicas`
- `kube_horizontalpodautoscaler_status_desired_replicas`
- `container_cpu_usage_seconds_total`
- `container_memory_working_set_bytes`

### 🔧 Setup Commands

```bash
# Setup auto-scaling (installs Metrics Server + HPA)
./scripts/setup-autoscaling.sh

# Setup VPA (Vertical Pod Autoscaler)
./scripts/setup-vpa.sh

# Test VPA functionality
./scripts/test-vpa.sh

# Fix Grafana Prometheus data source
./scripts/fix-grafana-prometheus-datasource.sh

# Setup Grafana HPA dashboard
./scripts/setup-grafana-hpa-dashboard-simple.sh

# Monitor HPA status
kubectl get hpa -n k8s-demo -w

# Monitor VPA status
kubectl get vpa -n k8s-demo -w

# Check resource usage
kubectl top pods -n k8s-demo
```

## 🔧 Useful Commands

```bash
# Check pods
kubectl get pods -n k8s-demo

# Check services
kubectl get services -n k8s-demo

# Application logs
kubectl logs -f deployment/backend -n k8s-demo

# Access pod
kubectl exec -it <pod-name> -n k8s-demo -- /bin/bash

# Auto-scaling commands
kubectl get hpa -n k8s-demo
kubectl describe hpa backend-hpa -n k8s-demo
kubectl top pods -n k8s-demo

# VPA commands
kubectl get vpa -n k8s-demo
kubectl describe vpa backend-vpa -n k8s-demo
kubectl patch vpa backend-vpa -n k8s-demo --type='merge' -p='{"spec":{"updatePolicy":{"updateMode":"Initial"}}}'

# Load testing
./scripts/load-test.sh [duration] [users] [ramp-up] [cpu]

# Delete everything
./scripts/cleanup.sh
```

## 🆕 Recent Improvements

### 🎯 Helm Chart Implementation
- **Complete Helm Chart**: Full chart structure with templates for all components
- **Multi-Environment Support**: Separate dev and staging environments with isolated configurations
- **Helper Templates**: Reusable template functions for consistent ingress path management
- **Dependency Management**: MariaDB, Prometheus, and Grafana as Helm chart dependencies

### 🔧 Infrastructure Improvements
- **Database Migration**: Migrated from MySQL to MariaDB for better compatibility
- **Dynamic Nginx Configuration**: Implemented envsubst for environment-agnostic frontend configuration
- **Subpath Support**: Configured Prometheus and Grafana to work properly in subpaths
- **Environment Variables**: Dynamic backend service discovery for frontend containers

### 🚀 Deployment Enhancements
- **Automated Scripts**: Comprehensive Helm deployment, upgrade, and cleanup scripts
- **Environment Isolation**: Separate namespaces and configurations for each environment
- **Configuration Management**: Environment-specific values files with proper inheritance
- **Cleanup**: Removed hardcoded paths and unused configuration files

### 🐛 Bug Fixes
- **Node-Exporter Issues**: Disabled node-exporter to avoid Docker Desktop compatibility problems
- **Ingress Conflicts**: Resolved path conflicts between static files and application routes
- **MIME Type Issues**: Fixed frontend static file serving with proper path ordering
- **Service Discovery**: Implemented proper backend service discovery for frontend

## 🎯 Learning Objectives

### ✅ Kubernetes Fundamentals
- [x] Pods, Deployments, Services, Ingress
- [x] Persistent Volumes and Storage Classes
- [x] Secrets and ConfigMaps
- [x] Namespaces and Resource Management

### ✅ Container Orchestration
- [x] Multi-container applications
- [x] Service discovery and networking
- [x] Health checks and probes
- [x] Rolling updates and rollbacks

### ✅ Monitoring and Observability
- [x] Metrics collection with Prometheus
- [x] Dashboard creation with Grafana
- [x] Alerting and notification setup
- [x] Application performance monitoring

### ✅ CI/CD and DevOps
- [x] Automated testing and deployment
- [x] Container registry integration
- [x] Security best practices
- [x] Resource optimization

## 🔧 Recent Fixes & Improvements

### Monitoring Configuration
- **Prometheus**: Configured with `--web.external-url` for proper Ingress routing
- **Grafana**: Configured with `GF_SERVER_ROOT_URL` and `GF_SERVER_SERVE_FROM_SUB_PATH` for subpath support
- **Ingress**: Optimized routing rules for all services

### Application Fixes
- **Backend**: Fixed metrics endpoint Promise handling
- **Frontend**: Improved error handling and API response processing
- **Docker**: Updated build processes for better compatibility

### Infrastructure Improvements
- **MySQL**: Corrected environment variables and initialization
- **Scripts**: Enhanced setup and deployment automation
- **Documentation**: Updated troubleshooting and monitoring guides

## 📝 Commit Roadmap

### Phase 1: Base Structure
- [x] Folder structure
- [x] Initial documentation
- [x] Base scripts

### Phase 2: Applications
- [x] React Frontend
- [x] Node.js Backend
- [x] MySQL Configuration

### Phase 3: Kubernetes
- [x] Base manifests
- [x] Deployments
- [x] Services and Ingress

### Phase 4: Monitoring
- [x] Prometheus
- [x] Grafana
- [x] Dashboards

### Phase 5: HELM
- [ ] Helm charts creation
- [ ] Application packaging
- [ ] Values management
- [ ] Chart dependencies

### Phase 6: CI/CD
- [ ] GitHub Actions
- [ ] Docker Registry
- [ ] Automated deploy with Helm charts

### Phase 7: ArgoCD
- [ ] GitOps setup
- [ ] Application definitions
- [ ] Sync policies
- [ ] Multi-environment management

## 🚀 Next Steps for Enhancement

### Advanced Monitoring
- [ ] Custom dashboards for business metrics
- [ ] Alerting rules for critical issues
- [ ] Log aggregation with ELK stack

### Security Enhancements
- [ ] Network policies implementation
- [ ] RBAC configuration
- [ ] Secrets management with external tools

### Scalability Features
- [x] Horizontal Pod Autoscaling (HPA)
- [x] Vertical Pod Autoscaling (VPA)
- [ ] Cluster autoscaling

### Advanced CI/CD
- [ ] Blue-green deployments
- [ ] Canary releases
- [ ] Feature flags integration

## 🤝 Contributing

1. Fork the project
2. Create a branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## 📄 License

This project is for educational purposes.
