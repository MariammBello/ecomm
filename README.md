# Simple E-commerce Application

A minimal e-commerce application to demonstrate CI/CD, Kubernetes, and cloud migration concepts.

## Components

1. **Frontend**: Simple static HTML/JS application
   - Vanilla JavaScript
   - Served via Nginx
   - Communicates with backend API

2. **Backend**: Flask REST API
   - Python Flask application
   - MongoDB database
   - Basic CRUD operations

3. **Database**: MongoDB
   - Persistent storage via StatefulSet
   - Single replica for simplicity

## Infrastructure

### Local Development (MicroK8s)
- Kubernetes cluster using MicroK8s
- Container registry at ghcr.io
- ArgoCD for GitOps deployments
- Prometheus Stack for monitoring

### CI/CD Pipeline
1. GitHub Actions workflow triggers on push to main
2. Builds Docker images for frontend and backend
3. Pushes images to GitHub Container Registry
4. Updates Kubernetes manifests with new image tags
5. ArgoCD automatically syncs changes to cluster

## Setup Instructions

1. **Prerequisites**
   ```bash
   # Install MicroK8s
   sudo snap install microk8s --classic
   
   # Enable required addons
   microk8s enable dns ingress storage
   ```

2. **Deploy ArgoCD**
   ```bash
   # Will be handled by Terraform
   ```

3. **Deploy Prometheus Stack**
   ```bash
   # Will be handled by Ansible
   ```

4. **Deploy Application**
   ```bash
   # ArgoCD will handle this automatically
   ```

## Monitoring
- Prometheus for metrics collection
- Grafana for visualization
- Basic dashboards for:
  - Node metrics
  - Pod metrics
  - Application metrics

## Migration Path
1. Survey current environment
2. Document dependencies and configurations
3. Plan migration strategy (lift-and-shift vs. re-architect)
4. Consider hybrid options
5. Implement monitoring and observability
6. Plan backup and disaster recovery

## Next Steps
1. Set up Terraform for ArgoCD deployment
2. Configure Ansible for Prometheus Stack
3. Add more monitoring metrics
4. Document migration strategies
