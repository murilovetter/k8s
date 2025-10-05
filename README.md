# 🚀 Kubernetes Infrastructure - Complete Learning

This project demonstrates a complete Kubernetes infrastructure with frontend, backend applications and MySQL database, including monitoring and CI/CD.

## 📋 Overview

### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                DOCKER DESKTOP + KUBERNETES                 │
├─────────────────────────────────────────────────────────────┤
│  Frontend (React)     │  Backend (Node.js)  │  MySQL       │
│  - Nginx Ingress      │  - API REST         │  - Database  │
│  - Service            │  - Service          │  - Service   │
│  - Deployment         │  - Deployment       │  - Deployment│
│                       │                     │  - PVC       │
├─────────────────────────────────────────────────────────────┤
│  Monitoring: Prometheus + Grafana                           │
│  Storage: Persistent Volumes (Docker Desktop)              │
│  Ingress: Nginx Ingress Controller                          │
└─────────────────────────────────────────────────────────────┘
```

### Components
- **Frontend**: React + Nginx
- **Backend**: Node.js + Express + MySQL2
- **Database**: MySQL 8.0
- **Monitoring**: Prometheus + Grafana
- **Ingress**: Nginx Ingress Controller
- **Storage**: Persistent Volumes

## 🛠️ Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl installed and configured
- Node.js 18+ (for local development)
- Git

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone <your-repository>
cd k8s

# 2. Run setup
./scripts/setup.sh

# 3. Deploy the application
./scripts/deploy.sh

# 4. Check status
kubectl get pods -n k8s-demo
```

## 📁 Project Structure

```
k8s/
├── apps/                    # Applications
│   ├── frontend/           # React + Nginx
│   ├── backend/            # Node.js + Express
│   └── database/           # MySQL
├── k8s-manifests/          # Kubernetes Manifests
│   ├── namespace.yaml
│   ├── mysql/
│   ├── backend/
│   ├── frontend/
│   ├── ingress/
│   └── monitoring/
├── docker/                 # Dockerfiles
│   ├── Dockerfile.frontend
│   ├── Dockerfile.backend
│   └── mysql-init/
├── scripts/                # Automation Scripts
│   ├── setup.sh
│   ├── deploy.sh
│   └── cleanup.sh
└── docs/                   # Documentation
    ├── DEPLOY.md
    ├── MONITORING.md
    └── TROUBLESHOOTING.md
```

## 📚 Documentation

- [Deploy Guide](docs/DEPLOY.md)
- [Monitoring](docs/MONITORING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

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

# Delete everything
./scripts/cleanup.sh
```

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

### Phase 5: CI/CD
- [ ] GitHub Actions
- [ ] Docker Registry
- [ ] Automated deploy

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
- [ ] Horizontal Pod Autoscaling (HPA)
- [ ] Vertical Pod Autoscaling (VPA)
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
