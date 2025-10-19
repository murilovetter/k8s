# 🚀 Helm Documentation - k8s-demo

Esta documentação explica como usar o Helm para gerenciar a aplicação k8s-demo.

## 📋 Visão Geral

O projeto k8s-demo agora utiliza Helm para gerenciar deployments, facilitando:
- **Deploy por ambiente**: dev, staging, prod
- **Dependencies**: MySQL, Prometheus, Grafana
- **Autoscaling**: HPA configurado
- **Templates**: Reutilização de código
- **Values**: Configuração por ambiente

## 🏗️ Estrutura do Chart

```
charts/k8s-demo/
├── Chart.yaml                    # Metadados do chart
├── values.yaml                   # Values padrão
└── templates/                    # Templates Kubernetes
    ├── _helpers.tpl             # Funções auxiliares
    ├── frontend/                # Templates do frontend
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── configmap.yaml
    ├── backend/                 # Templates do backend
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── secret.yaml
    ├── ingress/                 # Templates do ingress
    │   └── ingress.yaml
    └── autoscaling/             # Templates de autoscaling
        └── hpa/
            ├── backend-hpa.yaml
            └── frontend-hpa.yaml
```

## 📁 Values Files

### Estrutura de Values
- **values-dev.yaml**: Configurações para desenvolvimento
- **values-staging.yaml**: Configurações para homologação
- **values-prod.yaml**: Configurações para produção

### Configurações Principais

#### Global
```yaml
global:
  namespace: k8s-demo-dev
  environment: dev
  domain: k8s-demo.local
```

#### Frontend
```yaml
frontend:
  enabled: true
  replicas: 2
  image:
    repository: k8s-demo/frontend
    tag: latest
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 8
    targetCPU: 60
    targetMemory: 70
```

#### Backend
```yaml
backend:
  enabled: true
  replicas: 2
  image:
    repository: k8s-demo/backend
    tag: latest
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPU: 70
    targetMemory: 80
  env:
    MYSQL_HOST: mysql
    MYSQL_PORT: 3306
    MYSQL_DATABASE: k8s_demo
    MYSQL_USER: app_user
    MYSQL_PASSWORD: dev-password
```

## 🔗 Dependencies

O chart utiliza dependencies oficiais:

### MySQL (Bitnami)
```yaml
dependencies:
  - name: mysql
    version: "9.4.0"
    repository: "https://charts.bitnami.com/bitnami"
    condition: mysql.enabled
```

### Prometheus (Community)
```yaml
dependencies:
  - name: prometheus
    version: "25.8.0"
    repository: "https://prometheus-community.github.io/helm-charts"
    condition: prometheus.enabled
```

### Grafana (Official)
```yaml
dependencies:
  - name: grafana
    version: "7.0.0"
    repository: "https://grafana.github.io/helm-charts"
    condition: grafana.enabled
```

## 🚀 Scripts de Automação

### 1. Setup do Helm
```bash
./scripts/helm-setup.sh
```
- Adiciona repositórios Helm
- Atualiza dependencies
- Configura ambiente

### 2. Deploy
```bash
# Deploy em desenvolvimento
./scripts/helm-deploy.sh dev

# Deploy em staging
./scripts/helm-deploy.sh staging

# Deploy em produção
./scripts/helm-deploy.sh prod

# Deploy com dry-run
./scripts/helm-deploy.sh dev --dry-run

# Deploy com debug
./scripts/helm-deploy.sh dev --debug
```

### 3. Upgrade
```bash
# Upgrade em desenvolvimento
./scripts/helm-upgrade.sh dev

# Upgrade com dry-run
./scripts/helm-upgrade.sh dev --dry-run
```

### 4. Cleanup
```bash
# Limpar ambiente específico
./scripts/helm-cleanup.sh dev

# Limpar todos os ambientes
./scripts/helm-cleanup.sh all

# Limpar com confirmação forçada
./scripts/helm-cleanup.sh dev --force
```

## 🎯 Comandos Helm Diretos

### Setup Inicial
```bash
# Adicionar repositórios
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Atualizar repositórios
helm repo update

# Atualizar dependencies
helm dependency update ./charts/k8s-demo
```

### Deploy
```bash
# Deploy em desenvolvimento
helm install k8s-demo-dev ./charts/k8s-demo \
  -f values-dev.yaml \
  --namespace k8s-demo-dev \
  --create-namespace

# Deploy em produção
helm install k8s-demo-prod ./charts/k8s-demo \
  -f values-prod.yaml \
  --namespace k8s-demo-prod \
  --create-namespace
```

### Upgrade
```bash
# Upgrade
helm upgrade k8s-demo-dev ./charts/k8s-demo \
  -f values-dev.yaml \
  --namespace k8s-demo-dev
```

### Status e Monitoramento
```bash
# Listar releases
helm list --all-namespaces

# Status do release
helm status k8s-demo-dev -n k8s-demo-dev

# Histórico de releases
helm history k8s-demo-dev -n k8s-demo-dev

# Rollback
helm rollback k8s-demo-dev 1 -n k8s-demo-dev
```

### Cleanup
```bash
# Uninstall release
helm uninstall k8s-demo-dev -n k8s-demo-dev

# Deletar namespace
kubectl delete namespace k8s-demo-dev
```

## 🌐 Acesso por Ambiente

### Desenvolvimento
- **Frontend**: http://k8s-demo.local
- **Backend API**: http://k8s-demo.local/api
- **Prometheus**: http://k8s-demo.local/prometheus
- **Grafana**: http://k8s-demo.local/grafana

### Staging
- **Frontend**: http://k8s-demo.staging.com
- **Backend API**: http://k8s-demo.staging.com/api
- **Prometheus**: http://k8s-demo.staging.com/prometheus
- **Grafana**: http://k8s-demo.staging.com/grafana

### Produção
- **Frontend**: http://k8s-demo.prod.com
- **Backend API**: http://k8s-demo.prod.com/api
- **Prometheus**: http://k8s-demo.prod.com/prometheus
- **Grafana**: http://k8s-demo.prod.com/grafana

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Dependencies não encontradas
```bash
# Atualizar dependencies
helm dependency update ./charts/k8s-demo

# Verificar dependencies
helm dependency list ./charts/k8s-demo
```

#### 2. Template errors
```bash
# Validar templates
helm template k8s-demo ./charts/k8s-demo -f values-dev.yaml

# Dry-run para debug
helm install k8s-demo ./charts/k8s-demo -f values-dev.yaml --dry-run --debug
```

#### 3. Namespace não existe
```bash
# Criar namespace
kubectl create namespace k8s-demo-dev

# Ou usar --create-namespace
helm install k8s-demo-dev ./charts/k8s-demo -f values-dev.yaml --create-namespace
```

#### 4. Pods não ficam ready
```bash
# Verificar status dos pods
kubectl get pods -n k8s-demo-dev

# Verificar logs
kubectl logs -f deployment/k8s-demo-dev-backend -n k8s-demo-dev

# Verificar eventos
kubectl get events -n k8s-demo-dev --sort-by='.lastTimestamp'
```

### Comandos Úteis

```bash
# Verificar recursos
kubectl get all -n k8s-demo-dev

# Verificar HPA
kubectl get hpa -n k8s-demo-dev

# Verificar ingress
kubectl get ingress -n k8s-demo-dev

# Verificar secrets
kubectl get secrets -n k8s-demo-dev

# Verificar configmaps
kubectl get configmaps -n k8s-demo-dev

# Verificar persistent volumes
kubectl get pv,pvc -n k8s-demo-dev
```

## 📊 Monitoramento

### HPA Status
```bash
# Verificar HPA
kubectl get hpa -n k8s-demo-dev

# Detalhes do HPA
kubectl describe hpa k8s-demo-dev-backend-hpa -n k8s-demo-dev

# Monitorar em tempo real
kubectl get hpa -n k8s-demo-dev -w
```

### Resource Usage
```bash
# Uso de recursos
kubectl top pods -n k8s-demo-dev

# Uso de nodes
kubectl top nodes
```

### Logs
```bash
# Logs do backend
kubectl logs -f deployment/k8s-demo-dev-backend -n k8s-demo-dev

# Logs do frontend
kubectl logs -f deployment/k8s-demo-dev-frontend -n k8s-demo-dev

# Logs do MySQL
kubectl logs -f statefulset/k8s-demo-dev-mysql -n k8s-demo-dev
```

## 🎯 Próximos Passos

### Phase 6: CI/CD
- [ ] GitHub Actions
- [ ] Docker Registry
- [ ] Automated deploy with Helm charts

### Phase 7: ArgoCD
- [ ] GitOps setup
- [ ] Application definitions
- [ ] Sync policies
- [ ] Multi-environment management

## 📚 Referências

- [Helm Documentation](https://helm.sh/docs/)
- [Bitnami Charts](https://charts.bitnami.com/bitnami)
- [Prometheus Community Charts](https://prometheus-community.github.io/helm-charts)
- [Grafana Charts](https://grafana.github.io/helm-charts)
- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

