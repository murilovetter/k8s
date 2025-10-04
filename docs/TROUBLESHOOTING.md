# 🔧 Troubleshooting - Kubernetes

This guide helps resolve common problems in the Kubernetes infrastructure.

## 🚨 Common Problems

### 1. Pods not starting

#### Symptoms
```bash
kubectl get pods -n k8s-demo
# NAME                     READY   STATUS    RESTARTS   AGE
# backend-xxx             0/1     Pending   0          5m
```

#### Diagnosis
```bash
# Check events
kubectl get events -n k8s-demo --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name> -n k8s-demo

# View logs
kubectl logs <pod-name> -n k8s-demo
```

#### Solutions
- **ImagePullBackOff**: Check if image exists
- **CrashLoopBackOff**: Check logs and configurations
- **Pending**: Check available resources

### 2. Services not working

#### Symptoms
```bash
kubectl get services -n k8s-demo
# NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
# backend   ClusterIP   10.96.0.1    <none>        3000/TCP  5m
```

#### Diagnosis
```bash
# Check endpoints
kubectl get endpoints -n k8s-demo

# Test connectivity
kubectl exec -it <pod-name> -n k8s-demo -- curl http://backend:3000/health

# Check labels
kubectl get pods -n k8s-demo --show-labels
```

#### Solutions
- **No endpoints**: Check pod and service labels
- **Connectivity**: Check network policies
- **DNS**: Check CoreDNS

### 3. Ingress not working

#### Symptoms
```bash
kubectl get ingress -n k8s-demo
# NAME              CLASS   HOSTS              ADDRESS   PORTS   AGE
# k8s-demo-ingress  nginx   k8s-demo.local             80      5m
```

#### Diagnosis
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress
kubectl describe ingress k8s-demo-ingress -n k8s-demo

# Test connectivity
curl -H "Host: k8s-demo.local" http://localhost
```

#### Solutions
- **No ADDRESS**: Check ingress controller
- **404**: Check routing rules
- **DNS**: Check /etc/hosts

## 🔍 Diagnostic Commands

### 1. Check General Status
```bash
# Pod status
kubectl get pods -n k8s-demo -o wide

# Service status
kubectl get services -n k8s-demo

# Ingress status
kubectl get ingress -n k8s-demo

# Persistent volumes status
kubectl get pv,pvc -n k8s-demo
```

### 2. Check Logs
```bash
# Pod logs
kubectl logs <pod-name> -n k8s-demo

# Follow logs
kubectl logs -f <pod-name> -n k8s-demo

# Deployment logs
kubectl logs -f deployment/backend -n k8s-demo

# Previous logs
kubectl logs <pod-name> -n k8s-demo --previous
```

### 3. Check Resources
```bash
# Resource usage
kubectl top pods -n k8s-demo
kubectl top nodes

# Describe resources
kubectl describe pod <pod-name> -n k8s-demo
kubectl describe service <service-name> -n k8s-demo
kubectl describe ingress <ingress-name> -n k8s-demo
```

### 4. Check Network
```bash
# Test DNS
kubectl exec -it <pod-name> -n k8s-demo -- nslookup kubernetes.default

# Test connectivity
kubectl exec -it <pod-name> -n k8s-demo -- curl http://backend:3000/health

# Check network policies
kubectl get networkpolicies -n k8s-demo
```

## 🐛 Specific Problems

### 1. MySQL not connecting

#### Diagnosis
```bash
# Check MySQL logs
kubectl logs -f deployment/mysql -n k8s-demo

# Test connectivity
kubectl exec -it <backend-pod> -n k8s-demo -- telnet mysql 3306

# Check secrets
kubectl get secrets -n k8s-demo
kubectl describe secret mysql-secret -n k8s-demo
```

#### Solutions
- **Connection refused**: Check if MySQL is running
- **Credentials**: Check secrets
- **DNS**: Check if service is working

### 2. Backend not connecting to MySQL

#### Diagnosis
```bash
# Check backend logs
kubectl logs -f deployment/backend -n k8s-demo

# Check environment variables
kubectl exec -it <backend-pod> -n k8s-demo -- env | grep MYSQL

# Test connectivity
kubectl exec -it <backend-pod> -n k8s-demo -- curl http://localhost:3000/health
```

#### Solutions
- **Environment variables**: Check ConfigMap and Secret
- **Connection**: Check connection string
- **Timeout**: Check if MySQL is ready

### 3. Frontend not loading

#### Diagnosis
```bash
# Check frontend logs
kubectl logs -f deployment/frontend -n k8s-demo

# Test connectivity
kubectl exec -it <frontend-pod> -n k8s-demo -- curl http://localhost:80

# Check ingress
kubectl describe ingress k8s-demo-ingress -n k8s-demo
```

#### Solutions
- **Build**: Check if application was built
- **Nginx**: Check Nginx configuration
- **Ingress**: Check routing rules

## 🔄 Recovery

### 1. Restart Deployments
```bash
# Restart a deployment
kubectl rollout restart deployment/backend -n k8s-demo

# Check rollout status
kubectl rollout status deployment/backend -n k8s-demo

# Rollback if necessary
kubectl rollout undo deployment/backend -n k8s-demo
```

### 2. Recreate Resources
```bash
# Delete and recreate a pod
kubectl delete pod <pod-name> -n k8s-demo

# Delete and recreate a deployment
kubectl delete deployment/backend -n k8s-demo
kubectl apply -f k8s-manifests/backend/
```

### 3. Complete Cleanup
```bash
# Delete namespace (removes everything)
kubectl delete namespace k8s-demo

# Check if it was removed
kubectl get namespaces

# Recreate namespace
kubectl apply -f k8s-manifests/namespace.yaml
```

## 📊 Problem Monitoring

### 1. Check Metrics
```bash
# Port forward to Prometheus
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo

# Access: http://localhost:9090
# Query: up{job="backend"}
```

### 2. Check Alerts
```bash
# Check active alerts
kubectl port-forward service/prometheus 9090:9090 -n k8s-demo

# Access: http://localhost:9090/alerts
```

### 3. Check Dashboards
```bash
# Port forward to Grafana
kubectl port-forward service/grafana 3000:3000 -n k8s-demo

# Access: http://localhost:3000
# Login: admin/admin
```

## 🚨 Critical Problems

### 1. Cluster not responding
```bash
# Check cluster status
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system
```

### 2. Storage not working
```bash
# Check persistent volumes
kubectl get pv,pvc -n k8s-demo

# Check storage class
kubectl get storageclass

# Check events
kubectl get events -n k8s-demo
```

### 3. Network not working
```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check network policies
kubectl get networkpolicies -n k8s-demo

# Test connectivity
kubectl exec -it <pod-name> -n k8s-demo -- ping 8.8.8.8
```

## 📞 Support

### 1. Collect Information
```bash
# Collect logs from all pods
kubectl logs --all-containers=true -n k8s-demo > logs.txt

# Collect events
kubectl get events -n k8s-demo > events.txt

# Collect status
kubectl get all -n k8s-demo > status.txt
```

### 2. Document Problem
- **Symptoms**: What is happening
- **Steps**: What was done
- **Logs**: Relevant logs
- **Configuration**: Manifests used

### 3. Useful Resources
- **Documentation**: https://kubernetes.io/docs/
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/kubernetes
- **GitHub Issues**: Project issues
