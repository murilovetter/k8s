# 🚀 Kubernetes Demo - Setup Final

## ✅ **O que Funciona:**

### **1. Aplicações:**
- ✅ **Frontend**: React app (2 réplicas)
- ✅ **Backend**: Node.js API (2 réplicas) 
- ✅ **MySQL**: Database (1 réplica)
- ✅ **Ingress**: Acesso via `k8s-demo.local`

### **2. Auto-scaling (HPA):**
- ✅ **Backend HPA**: 2-10 réplicas, CPU 70%, Memory 80%
- ✅ **Frontend HPA**: 2-8 réplicas, CPU 60%, Memory 70%
- ✅ **Metrics Server**: Coletando métricas de CPU/Memory

### **3. Monitoramento:**
- ✅ **Prometheus**: Coletando métricas
- ✅ **Grafana**: Dashboard funcionando
- ✅ **kube-state-metrics**: Expõe métricas do HPA
- ✅ **HPA Metrics Dashboard**: Dashboard com métricas reais

## 📋 **Scripts Funcionais:**

```bash
# Setup básico
./scripts/setup.sh

# Deploy aplicações
./scripts/deploy.sh

# Setup auto-scaling
./scripts/setup-autoscaling.sh

# Dashboard HPA
./scripts/create-hpa-metrics-dashboard.sh

# Teste de carga
./scripts/load-test.sh 300 50 60

# Parar teste de carga
./scripts/stop-load-test.sh

# Limpeza completa
./scripts/cleanup.sh
```

## 🎯 **Dashboard que Funciona:**

### **HPA Metrics Dashboard:**
- **Arquivo**: `/tmp/hpa-metrics-dashboard.json`
- **Import**: Grafana > + > Import > Copy & Paste
- **Métricas**:
  - HPA Replicas (Current vs Desired)
  - HPA Limits (Min vs Max)
  - Deployment Replicas (Total vs Ready)
  - Services Status

## 🔍 **Comandos Úteis:**

### **Monitorar HPA:**
```bash
# Status do HPA
kubectl get hpa -n k8s-demo

# Detalhes do HPA
kubectl describe hpa backend-hpa -n k8s-demo

# Monitorar em tempo real
kubectl get hpa -n k8s-demo -w
```

### **Monitorar Pods:**
```bash
# Status dos pods
kubectl get pods -n k8s-demo

# Uso de recursos
kubectl top pods -n k8s-demo

# Monitorar em tempo real
kubectl get pods -n k8s-demo -w
```

### **Testar Auto-scaling:**
```bash
# Gerar carga
./scripts/load-test.sh 300 50 60

# Parar carga
./scripts/stop-load-test.sh
```

## 🌐 **Acesso:**

### **Aplicações:**
- **Frontend**: http://k8s-demo.local
- **Backend**: http://k8s-demo.local/api
- **Grafana**: http://k8s-demo.local/grafana (admin/admin)
- **Prometheus**: http://k8s-demo.local/prometheus

### **Port Forward (alternativo):**
```bash
# Frontend
kubectl port-forward service/frontend 3000:80 -n k8s-demo

# Backend
kubectl port-forward service/backend 3001:3000 -n k8s-demo

# Grafana
kubectl port-forward service/grafana 3000:3000 -n k8s-demo

# Prometheus
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo
```

## 📊 **Métricas Disponíveis:**

### **HPA Metrics (kube-state-metrics):**
- `kube_horizontalpodautoscaler_status_current_replicas`
- `kube_horizontalpodautoscaler_status_desired_replicas`
- `kube_horizontalpodautoscaler_spec_min_replicas`
- `kube_horizontalpodautoscaler_spec_max_replicas`
- `kube_deployment_status_replicas`
- `kube_deployment_status_replicas_ready`

### **Application Metrics:**
- `up{job="backend"}` - Status do backend
- `up{job="prometheus"}` - Status do Prometheus
- `up{job="kube-state-metrics"}` - Status do kube-state-metrics

## 🚀 **Teste Completo:**

### **1. Setup:**
```bash
./scripts/setup.sh
./scripts/deploy.sh
./scripts/setup-autoscaling.sh
```

### **2. Dashboard:**
```bash
./scripts/create-hpa-metrics-dashboard.sh
# Import no Grafana: http://k8s-demo.local/grafana
```

### **3. Teste de Auto-scaling:**
```bash
# Em um terminal
kubectl get hpa -n k8s-demo -w

# Em outro terminal
./scripts/load-test.sh 300 50 60

# Parar quando quiser
./scripts/stop-load-test.sh
```

## 🧹 **Limpeza:**
```bash
./scripts/cleanup.sh
```

## ✅ **Status Final:**
- ✅ Cluster limpo e funcional
- ✅ Aplicações rodando
- ✅ HPA funcionando
- ✅ Dashboard com métricas reais
- ✅ Teste de carga funcionando
- ✅ Monitoramento completo

**🎉 Projeto funcionando 100%!**
