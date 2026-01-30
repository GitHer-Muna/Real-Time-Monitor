# Cloud-Native Inventory Management System

Full-stack inventory management application built with React, Node.js, and MySQL, deployed on AWS EKS with Kubernetes.

## Tech Stack

- **Frontend**: React 18, Material-UI, Nginx
- **Backend**: Node.js, Express, MySQL2
- **Database**: MySQL 8.0
- **Infrastructure**: Docker, Kubernetes, Terraform
- **Cloud**: AWS (EKS, ECR, VPC, ALB)
- **CI/CD**: GitHub Actions

## Features

- Product, Category, and Warehouse management
- RESTful API with CRUD operations
- Auto-scaling (CPU-based)
- Multi-AZ deployment
- Persistent storage

## Project Structure

```
CloudNative-Application/
├── backend/              # Node.js API
│   ├── src/
│   │   ├── routes/       # API endpoints
│   │   ├── models/       # Database models
│   │   └── config/       # Configuration
│   └── Dockerfile
├── frontend/             # React app
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── services/
│   └── Dockerfile
├── database/             # MySQL schemas
├── k8s/                  # Kubernetes manifests
├── terraform/            # Infrastructure as Code
└── docker-compose.yml    # Local development
```

## Getting Started

### Local Development

**Prerequisites**: Docker Desktop, Docker Compose

```bash
git clone <your-repo-url>
cd CloudNative-Application
docker compose up --build
```

Access:
- Frontend: http://localhost:3000
- Backend: http://localhost:5000
- Database: localhost:3307

## AWS Deployment (Automated)

### One-Time Setup

**Prerequisites**: AWS CLI configured, Terraform v1.5+

1. **Provision Infrastructure**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS details
terraform init && terraform apply
```

2. **Configure GitHub Secrets**

Add these secrets to your GitHub repository settings:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

3. **Deploy Application**
```bash
git push origin main
```

GitHub Actions will automatically:
- Build Docker images
- Push to Amazon ECR
- Deploy to Kubernetes
- Configure auto-scaling

**Deployment time**: ~5-7 minutes after push

### Access Your Application
```bash
kubectl get svc frontend-service -n inventory-system
# Use the EXTERNAL-IP from the output
```

## Useful Commands

**Local Development**
```bash
docker compose up -d              # Start in background
docker compose logs -f backend    # View logs
docker compose down -v            # Stop and remove
```

**Kubernetes**
```bash
kubectl get pods -n inventory-system                    # Pod status
kubectl logs -f deployment/backend -n inventory-system  # View logs
kubectl get hpa -n inventory-system                     # Autoscaling status
kubectl scale deployment backend --replicas=3 -n inventory-system
```

**Terraform**
```bash
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform destroy   # Remove infrastructure
```

## CI/CD Pipeline

The project uses GitHub Actions for automated deployment:

**Workflow**:
1. Push code to `main` branch
2. Build workflow runs automatically
3. Docker images built and pushed to ECR
4. Deploy workflow triggers on successful build
5. Application deployed to Kubernetes with zero downtime

**Manual trigger**: Go to Actions tab → Select workflow → Run workflow

## Cleanup

```bash
# Delete Kubernetes resources first (removes LoadBalancers and EBS volumes)
kubectl delete namespace inventory-system

# Destroy all AWS infrastructure (including ECR repositories)
cd terraform
terraform destroy
```

## License

MIT License

