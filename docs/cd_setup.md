# Continuous Delivery (CD) Setup Guide

This guide provides detailed instructions for setting up the CD pipeline using Kubernetes and ArgoCD.

## Prerequisites

Before starting, ensure you have:
- A Linux VM with sudo access
- Git installed and configured
- Docker installed
- Access to your GitHub repository
- Minimum system requirements:
  - 2 CPUs
  - 2GB RAM
  - 20GB disk space

## 1. Initial VM Setup

### 1.1 Clone Repository
```bash
# Clone the repository
git clone git@github.com:MariammBello/ecomm.git
cd ecomm

# Verify git setup
git status
```

### 1.2 Clean Up Repository (Optional)
```bash
# Keep only CD-related files
mkdir -p cd_setup
cp -r terraform cd_setup/
cp -r ansible cd_setup/
cp -r k8s cd_setup/
cp *.md cd_setup/
```

## 2. Kubernetes Setup

### 2.1 Install Prerequisites
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

### 2.2 Install Kubernetes Components
```bash
# Add Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 2.3 Initialize Kubernetes Cluster
```bash
# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Allow scheduling on control-plane
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### 2.4 Verify Cluster Setup
```bash
# Check node status
kubectl get nodes

# Expected output:
# NAME         STATUS   ROLES           AGE   VERSION
# your-node    Ready    control-plane   1m    v1.xx.x

# Check system pods
kubectl get pods --all-namespaces

# All pods should show 'Running' status
```

## 3. GitHub Configuration

### 3.1 Create GitHub Token
1. Go to GitHub → Settings → Developer Settings → Personal Access Tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - `read:packages` (for pulling images)
   - `repo` (for repository access)
4. Copy the generated token

### 3.2 Configure Token
```bash
# Export token (replace with your actual token)
export GITHUB_TOKEN=your_token_here

# Verify token is set
echo $GITHUB_TOKEN
```

## 4. ArgoCD Deployment

### 4.1 Install Terraform
```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install Terraform
sudo apt-get update
sudo apt-get install -y terraform
```

### 4.2 Deploy ArgoCD
```bash
# Navigate to Terraform directory
cd terraform/argocd

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply configuration
terraform apply
```

### 4.3 Verify ArgoCD Installation
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Expected output:
# NAME                                  READY   STATUS    RESTARTS   AGE
# argocd-application-controller-0       1/1     Running   0          1m
# argocd-dex-server-xxxxxx             1/1     Running   0          1m
# argocd-redis-xxxxxx                  1/1     Running   0          1m
# argocd-repo-server-xxxxxx            1/1     Running   0          1m
# argocd-server-xxxxxx                 1/1     Running   0          1m

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 5. Access ArgoCD UI

### 5.1 Port Forward Setup
```bash
# Start port forwarding
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5.2 Login to ArgoCD
1. Open browser: https://localhost:8080
2. Login credentials:
   - Username: admin
   - Password: (from step 4.3)

## 6. Verify Application Deployment

### 6.1 Check Application Status
```bash
# List applications
kubectl get applications -n argocd

# Check pods
kubectl get pods

# Check services
kubectl get services
```

### 6.2 Access Application
```bash
# Get service URLs
kubectl get svc

# For LoadBalancer services, use EXTERNAL-IP
# For NodePort services, use NODE-IP:NODE-PORT
```

## 7. Troubleshooting

### 7.1 Kubernetes Issues
```bash
# Check node status
kubectl describe node <node-name>

# Check pod logs
kubectl logs <pod-name> -n <namespace>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 7.2 ArgoCD Issues
```bash
# Check ArgoCD application status
kubectl describe application <app-name> -n argocd

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### 7.3 Common Problems and Solutions

1. **Pods Pending**
   - Check node resources
   - Verify node taints
   ```bash
   kubectl describe node | grep Taints
   ```

2. **Image Pull Errors**
   - Verify GitHub token
   - Check image path in manifests
   ```bash
   kubectl describe pod <pod-name>
   ```

3. **ArgoCD Sync Failed**
   - Check repository access
   - Verify manifest paths
   ```bash
   kubectl describe application <app-name> -n argocd
   ```

## 8. Maintenance

### 8.1 Regular Tasks
- Monitor resource usage
- Check application logs
- Review ArgoCD events
- Update GitHub tokens before expiry

### 8.2 Backup
```bash
# Backup Kubernetes config
cp ~/.kube/config ~/.kube/config.backup

# Backup ArgoCD settings
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml
```

## 9. Best Practices

1. **Security**
   - Regularly rotate GitHub tokens
   - Use RBAC for access control
   - Keep sensitive data in secrets

2. **Monitoring**
   - Set up resource monitoring
   - Configure alerts
   - Regular log review

3. **Updates**
   - Keep Kubernetes updated
   - Update ArgoCD regularly
   - Review security patches

## 10. Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
