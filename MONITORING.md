# Monitoring Setup - Prometheus & Grafana

This monitoring setup provides real-time metrics and visualization for the CloudNative application using Prometheus and Grafana.

## Architecture

- **Prometheus**: Collects and stores metrics from the backend API
- **Grafana**: Visualizes metrics with pre-configured dashboards
- **prom-client**: Node.js library for exposing metrics from the backend

## What's Being Monitored

### Application Metrics
- **Request Rate**: Number of HTTP requests per second
- **Response Time**: Average duration of HTTP requests
- **Error Rate**: Rate of 5xx HTTP errors
- **Active Connections**: Current number of active connections

### System Metrics
- **CPU Usage**: Process CPU utilization
- **Memory Usage**: Process memory consumption
- **Uptime**: Application uptime

## Local Development (Docker Compose)

### 1. Start All Services

```bash
docker-compose up -d
```

This starts:
- Backend API (port 5000)
- Prometheus (port 9090)
- Grafana (port 3001)
- Database (port 3307)

### 2. Access Monitoring Tools

**Prometheus**
- URL: http://localhost:9090
- Check targets: http://localhost:9090/targets
- Query metrics directly from the UI

**Grafana**
- URL: http://localhost:3001
- Default credentials: admin/admin
- Pre-configured dashboard: "CloudNative Application Monitoring"

**Backend Metrics Endpoint**
- URL: http://localhost:5000/metrics
- Raw Prometheus metrics in text format

### 3. Generate Traffic

To see metrics in action, generate some traffic:

```bash
# Install httpie or use curl
pip install httpie

# Make some requests
http GET http://localhost:5000/api/products
http GET http://localhost:5000/api/categories
http GET http://localhost:5000/health
```

### 4. View Dashboard

1. Open Grafana: http://localhost:3001
2. Go to Dashboards → CloudNative Application Monitoring
3. See real-time metrics updating

## Kubernetes Deployment

### 1. Apply Namespace (if not already created)

```bash
kubectl apply -f k8s/namespace.yaml
```

### 2. Deploy Prometheus

```bash
# Create RBAC permissions
kubectl apply -f k8s/monitoring/prometheus/rbac.yaml

# Deploy Prometheus
kubectl apply -f k8s/monitoring/prometheus/configmap.yaml
kubectl apply -f k8s/monitoring/prometheus/deployment.yaml
kubectl apply -f k8s/monitoring/prometheus/service.yaml
```

### 3. Deploy Grafana

```bash
kubectl apply -f k8s/monitoring/grafana/datasource-configmap.yaml
kubectl apply -f k8s/monitoring/grafana/dashboard-config.yaml
kubectl apply -f k8s/monitoring/grafana/dashboard.yaml
kubectl apply -f k8s/monitoring/grafana/deployment.yaml
kubectl apply -f k8s/monitoring/grafana/service.yaml
```

### 4. Access Services

**Prometheus**
```bash
# Using NodePort (port 30090)
kubectl get nodes -o wide
# Access via: http://<node-ip>:30090

# Or port-forward
kubectl port-forward -n cloudnative-app svc/prometheus 9090:9090
# Access via: http://localhost:9090
```

**Grafana**
```bash
# Using NodePort (port 30030)
# Access via: http://<node-ip>:30030

# Or port-forward
kubectl port-forward -n cloudnative-app svc/grafana 3001:3001
# Access via: http://localhost:3001
```

### 5. Verify Metrics Collection

```bash
# Check Prometheus targets
kubectl port-forward -n cloudnative-app svc/prometheus 9090:9090
# Visit http://localhost:9090/targets

# Check backend pods are being scraped
kubectl get pods -n cloudnative-app -l app=backend -o yaml | grep prometheus
```

## Understanding the Metrics

### HTTP Metrics

**http_requests_total**
- Counter of total HTTP requests
- Labels: method, route, status

**http_request_duration_seconds**
- Histogram of request durations
- Labels: method, route, status

**active_connections**
- Gauge of currently active connections

### Process Metrics (Auto-collected)

- `process_cpu_seconds_total`: Total CPU time
- `process_resident_memory_bytes`: Memory usage
- `nodejs_heap_size_total_bytes`: Node.js heap size
- `nodejs_eventloop_lag_seconds`: Event loop lag

## Common Prometheus Queries

```promql
# Request rate per second
rate(http_requests_total[5m])

# Average response time
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Error rate (5xx)
sum(rate(http_requests_total{status=~"5.."}[5m]))

# Memory usage
process_resident_memory_bytes

# CPU usage rate
rate(process_cpu_seconds_total[5m])
```

## Troubleshooting

### No Metrics in Prometheus

1. Check if backend is exposing metrics:
   ```bash
   curl http://localhost:5000/metrics
   ```

2. Check Prometheus targets:
   - Go to http://localhost:9090/targets
   - Ensure backend-api target is UP

3. Check backend logs:
   ```bash
   docker-compose logs backend
   ```

### Grafana Not Showing Data

1. Check datasource:
   - Go to Configuration → Data Sources
   - Test Prometheus connection

2. Check dashboard queries:
   - Click on panel → Edit
   - Check if query returns data

3. Verify time range:
   - Ensure time range includes recent data
   - Click refresh icon

## Cleanup

### Docker Compose
```bash
docker-compose down -v
```

### Kubernetes
```bash
kubectl delete -f k8s/monitoring/grafana/
kubectl delete -f k8s/monitoring/prometheus/
```

## Interview Tips

**Key Points to Mention:**

1. **Why Prometheus?**
   - Pull-based model (scrapes metrics)
   - Time-series database
   - Native Kubernetes support
   - Powerful query language (PromQL)

2. **Why Grafana?**
   - Industry standard for visualization
   - Rich dashboard capabilities
   - Multi-datasource support
   - Alerting features

3. **Metrics Types:**
   - Counter: Cumulative values (requests count)
   - Gauge: Current values (memory usage)
   - Histogram: Distributions (response times)
   - Summary: Similar to histogram with quantiles

4. **Best Practices:**
   - Use labels wisely (don't overuse)
   - Set appropriate scrape intervals
   - Monitor resource usage of monitoring tools
   - Create alerts for critical metrics

## Next Steps

- Add alerting rules to Prometheus
- Set up AlertManager for notifications
- Create more specific dashboards
- Add business metrics (products created, etc.)
- Implement distributed tracing (Jaeger)
