# Quick Start Guide

## Testing Monitoring Locally

### Option 1: With Docker (Recommended)

Make sure Docker Desktop is running, then:

```bash
# Start all services including monitoring
docker-compose up -d

# Wait for services to be ready (30-60 seconds)
docker-compose ps

# Generate some test traffic
curl http://localhost:5000/health
curl http://localhost:5000/api/products
curl http://localhost:5000/api/categories

# Access monitoring dashboards
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001
# Backend Metrics: http://localhost:5000/metrics
```

### Option 2: Manual Testing (Without Docker)

If Docker is not available, you can test the metrics endpoint:

1. Install backend dependencies:
```bash
cd backend
npm install
```

2. Start the backend (make sure MySQL is running):
```bash
npm run dev
```

3. View metrics:
```bash
curl http://localhost:5000/metrics
```

## Deploying to Kubernetes

### Prerequisites
- kubectl configured
- Kubernetes cluster running (minikube, kind, or EKS)
- Namespace created

### Deploy Monitoring Stack

```bash
# 1. Create namespace (if not exists)
kubectl apply -f k8s/namespace.yaml

# 2. Deploy Prometheus
kubectl apply -f k8s/monitoring/prometheus/

# 3. Deploy Grafana
kubectl apply -f k8s/monitoring/grafana/

# 4. Check deployment status
kubectl get pods -n cloudnative-app

# 5. Access Grafana
kubectl port-forward -n cloudnative-app svc/grafana 3001:3001

# 6. Access Prometheus
kubectl port-forward -n cloudnative-app svc/prometheus 9090:9090
```

## What Changed?

### New Files Created

**Monitoring Configuration (Local)**
- `monitoring/prometheus.yml` - Prometheus config for Docker Compose
- `monitoring/grafana/datasources.yml` - Grafana datasource config
- `monitoring/grafana/dashboards.yml` - Grafana dashboard provider
- `monitoring/grafana/dashboard.json` - Pre-built dashboard

**Kubernetes Manifests**
- `k8s/monitoring/prometheus/` - Prometheus K8s resources
- `k8s/monitoring/grafana/` - Grafana K8s resources

**Backend Code**
- `backend/src/config/metrics.js` - Prometheus metrics configuration
- `backend/src/middleware/metrics.js` - Express middleware for metrics
- `backend/package.json` - Added prom-client dependency

### Modified Files
- `backend/src/server.js` - Added /metrics endpoint
- `k8s/backend/deployment.yaml` - Added Prometheus annotations
- `docker-compose.yml` - Added Prometheus and Grafana services

## Setting Up Git Remote for Monitoring Repo

To push this monitoring branch to your new repo:

```bash
# Add the monitoring repo as a remote
git remote add monitoring https://github.com/GitHer-Muna/Real-Time-Monitor.git

# Verify remotes
git remote -v

# When ready to push (DON'T DO IT YET - test first!)
# git push monitoring monitoring:main
```

## Next Steps

1. Test locally with Docker Compose
2. Verify metrics are being collected
3. Check Grafana dashboards
4. Test on Kubernetes (optional)
5. Once confirmed working, push to monitoring repo

## Notes

- All monitoring code is on the `monitoring` branch
- The main application remains unchanged
- Monitoring is completely optional and can be removed without affecting the app
- Default Grafana credentials: admin/admin
