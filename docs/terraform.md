# Terraform and Kubernetes Setup Guide

This guide documents the complete setup process for Terraform, Kubernetes, and ArgoCD on a new VM.

## 1. System Prerequisites

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg
```

## 2. Install Docker

```bash
# Install Docker
sudo apt-get install -y docker.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
sudo usermod -aG docker $USER

# Verify Docker installation
docker --version
```

## 3. Install Kubernetes Components

```bash
# Add Kubernetes apt repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Verify installations
kubectl version --client
kubeadm version
```

## 4. Initialize Kubernetes Cluster

```bash
# Initialize the cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubectl for your user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Allow scheduling on control-plane node (for single-node setup)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Verify cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

## 5. Install Terraform

```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install Terraform
sudo apt-get update
sudo apt-get install -y terraform

# Verify Terraform installation
terraform version
```

## 6. Set Up ArgoCD Using Terraform

### Clone Repository
```bash
# Clone your repository (after setting up GitHub SSH)
git clone git@github.com:MariammBello/ecomm.git
cd ecomm/terraform/argocd
```

### Configure GitHub Token
```bash
# Create a GitHub personal access token with:
# - read:packages
# - repo
# Then export it:
export GITHUB_TOKEN=your_token_here
```

### Apply Terraform Configuration
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

## 7. Verify ArgoCD Installation

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD UI (choose one method)
# Method 1: Port forwarding
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Method 2: Get LoadBalancer IP (if configured)
kubectl get svc argocd-server -n argocd
```

## 8. Troubleshooting

### Kubernetes Issues
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check pod status
kubectl get pods --all-namespaces
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>
```

### Terraform Issues
```bash
# Clean up Terraform state
terraform destroy  # Only if you need to start over
rm -rf .terraform* terraform.tfstate*

# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```

### ArgoCD Issues
```bash
# Check ArgoCD components
kubectl get all -n argocd

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

## 9. Best Practices

1. **Security**:
   - Keep GitHub tokens secure
   - Regularly rotate credentials
   - Use RBAC for Kubernetes access

2. **Maintenance**:
   - Regularly update components
   - Monitor resource usage
   - Back up Kubernetes configurations

3. **Operations**:
   - Use version control for all configurations
   - Document all customizations
   - Maintain separate environments (dev/prod)

## 10. Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
