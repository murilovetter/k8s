# 📊 Monitoring - Prometheus + Grafana

This guide explains how to configure and use monitoring with Prometheus and Grafana.

## 🎯 Overview

### Monitoring Stack
- **Prometheus**: Collects and stores metrics
- **Grafana**: Visualization and dashboards
- **Node Exporter**: System metrics
- **cAdvisor**: Container metrics

### Collected Metrics
- **System**: CPU, Memory, Disk, Network
- **Application**: Requests, Latency, Errors
- **Kubernetes**: Pods, Services, Deployments
- **MySQL**: Connections, Queries, Performance

## 🚀 Installation

### 1. Deploy Monitoring
```bash
# Deploy Prometheus
kubectl apply -f k8s-manifests/monitoring/prometheus/

# Deploy Grafana
kubectl apply -f k8s-manifests/monitoring/grafana/

# Check status
kubectl get pods -n k8s-demo -l app=prometheus
kubectl get pods -n k8s-demo -l app=grafana
```

### 2. Configure Access
```bash
# Port forward to Prometheus
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo

# Port forward to Grafana
kubectl port-forward service/grafana 3000:3000 -n k8s-demo
```

## 📈 Prometheus

### 1. Access
- **URL**: http://localhost:9090
- **Features**: Queries, Targets, Alerts

### 2. Useful Queries

#### System
```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk Usage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
```

#### Application
```promql
# Requests per second
rate(http_requests_total[5m])

# Average latency
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

#### Kubernetes
```promql
# Pods per namespace
count by (namespace) (kube_pod_info)

# CPU per pod
sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))

# Memory per pod
sum by (pod) (container_memory_usage_bytes)
```

### 3. Targets
- **Node Exporter**: System metrics
- **cAdvisor**: Container metrics
- **Kube-state-metrics**: Kubernetes metrics
- **Application**: Custom metrics

## 📊 Grafana

### 1. Access
- **URL**: http://localhost:3000
- **Login**: admin
- **Password**: admin

### 2. Included Dashboards

#### System Dashboard
- **CPU Usage**: Per node and per pod
- **Memory Usage**: Per node and per pod
- **Disk Usage**: Per node
- **Network**: Inbound and outbound traffic

#### Application Dashboard
- **Requests**: Total and per second
- **Latency**: P50, P95, P99
- **Errors**: Error rate per endpoint
- **Throughput**: Requests per minute

#### Kubernetes Dashboard
- **Pods**: Status and resources
- **Services**: Endpoints and traffic
- **Deployments**: Replicas and status
- **Nodes**: Available resources

### 3. Configure Data Source

1. Go to **Configuration > Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. URL: `http://prometheus:9090`
5. Click **Save & Test**

### 4. Import Dashboards

#### System Dashboard (ID: 1860)
```bash
# Import Node Exporter dashboard
# ID: 1860
# URL: https://grafana.com/grafana/dashboards/1860
```

#### Kubernetes Dashboard (ID: 315)
```bash
# Import Kubernetes dashboard
# ID: 315
# URL: https://grafana.com/grafana/dashboards/315
```

## 🔔 Alerts

### 1. Configure Prometheus Alerts

#### High CPU
```yaml
groups:
- name: system
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "CPU usage is high"
      description: "CPU usage is above 80% for more than 5 minutes"
```

#### High Memory
```yaml
  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Memory usage is high"
      description: "Memory usage is above 80% for more than 5 minutes"
```

#### Pod Down
```yaml
  - alert: PodDown
    expr: kube_pod_status_phase{phase="Running"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Pod is down"
      description: "Pod {{ $labels.pod }} is down"
```

### 2. Configure Notifications

#### Slack
```yaml
# Configure Slack webhook
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#alerts'
    title: 'Kubernetes Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

## 🔧 Troubleshooting

### 1. Prometheus not collecting metrics
```bash
# Check targets
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo
# Access: http://localhost:9090/targets

# Check logs
kubectl logs -f deployment/prometheus -n k8s-demo
```

### 2. Grafana not connecting to Prometheus
```bash
# Check if Prometheus is running
kubectl get pods -n k8s-demo -l app=prometheus

# Test connectivity
kubectl exec -it <grafana-pod> -n k8s-demo -- curl http://prometheus:9090
```

### 3. Dashboards not loading
```bash
# Check Grafana logs
kubectl logs -f deployment/grafana -n k8s-demo

# Check data source
# Access: http://localhost:3000/datasources
```

## 📊 Custom Metrics

### 1. Add metrics to Backend

```javascript
// backend/app.js
const prometheus = require('prom-client');

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware to collect metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
    
    httpRequestTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .inc();
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

### 2. Configure ServiceMonitor

```yaml
# k8s-manifests/monitoring/servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-monitor
  namespace: k8s-demo
spec:
  selector:
    matchLabels:
      app: backend
  endpoints:
  - port: http
    path: /metrics
```

## 🎯 Next Steps

1. **Configure more specific Alerts**
2. **Add Custom Metrics**
3. **Implement Logs** with Loki
4. **Configure Dashboard Backup**
5. **Implement SLA monitoring**
