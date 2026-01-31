# Real-Time Application Monitoring

A monitoring solution for cloud-native applications using Prometheus and Grafana. This project collects metrics from a Node.js backend API and displays them on dashboards.

## What This Does

This monitoring setup tracks application performance and health:

- HTTP request rate and response times
- Error tracking for failed requests
- CPU and memory usage
- Active connections to the server
- Real-time visualization of all metrics

## Technologies Used

- Prometheus - collects and stores metrics
- Grafana - creates visual dashboards
- prom-client - Node.js metrics library
- Docker Compose - local development
- Kubernetes - production deployment

## Project Files

```
Real-Time-Monitor/
├── backend/
│   ├── src/
│   │   ├── config/metrics.js          # metrics configuration
│   │   └── middleware/metrics.js      # collect request data
│   └── package.json                   # added prom-client
├── k8s/
│   └── monitoring/
│       ├── prometheus/                # kubernetes configs
│       └── grafana/                   # kubernetes configs
├── monitoring/
│   ├── prometheus.yml                 # prometheus setup
│   └── grafana/                       # dashboard configs
├── docker-compose.yml                 # local testing
└── MONITORING.md                      # detailed guide
```

## How to Use

### Local Setup with Docker

Start all monitoring services:

```bash
docker-compose up -d
```

Access the dashboards:

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001
- Metrics endpoint: http://localhost:5000/metrics

Login to Grafana with username `admin` and password `admin`.

### Testing

Generate some traffic to see metrics:

```bash
curl http://localhost:5000/health
curl http://localhost:5000/api/products
curl http://localhost:5000/api/categories
```

Then check the Grafana dashboard to see request rates, response times, and resource usage.

### Kubernetes Deployment

Deploy Prometheus:

```bash
kubectl apply -f k8s/monitoring/prometheus/
```

Deploy Grafana:

```bash
kubectl apply -f k8s/monitoring/grafana/
```

Access via port-forward:

```bash
kubectl port-forward -n cloudnative-app svc/grafana 3001:3001
kubectl port-forward -n cloudnative-app svc/prometheus 9090:9090
```

## Metrics Collected

The backend exposes these metrics:

- http_requests_total - count of all HTTP requests
- http_request_duration_seconds - how long requests take
- active_connections - current connections
- process_cpu_seconds_total - CPU usage
- process_resident_memory_bytes - memory usage

## Dashboard Features

The Grafana dashboard shows:

- Request rate graph over time
- Average response time
- Total request count
- Error rate for 5xx responses
- Active connection count
- CPU usage graph
- Memory usage graph

All graphs update every 5 seconds.

## Configuration

Prometheus scrapes metrics from the backend every 15 seconds. You can change this in `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
```

The backend metrics endpoint is at `/metrics` and returns data in Prometheus format.

## Troubleshooting

If metrics are not showing:

1. Check if the backend is running
2. Visit http://localhost:5000/metrics to see raw data
3. Check Prometheus targets at http://localhost:9090/targets
4. Make sure all services are up with `docker-compose ps`

If Grafana shows no data:

1. Check the datasource connection in Grafana settings
2. Verify the time range is set to last 15 minutes
3. Click the refresh button on the dashboard

## Stop Services

Stop everything:

```bash
docker-compose down
```

Remove all data:

```bash
docker-compose down -v
```

## What I Learned

Working on this project taught me:

- How to add metrics to a Node.js application
- Setting up Prometheus for metric collection
- Creating Grafana dashboards
- Deploying monitoring tools on Kubernetes
- Understanding application observability

## Future Improvements

Things to add later:

- Email alerts when errors happen
- More detailed database query metrics
- Log aggregation with ELK stack
- Distributed tracing
- Custom business metrics

## Requirements

To run this project you need:

- Docker and Docker Compose
- Node.js 18 or higher (for local development)
- Kubernetes cluster (for production)
- kubectl configured

## Related Project

This monitoring setup is built for my cloud-native inventory management application. The main project is at [CloudNative-Application](https://github.com/GitHer-Muna/CloudNative-Application).

## License

MIT