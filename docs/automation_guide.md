# Infrastructure Automation Guide

## Checking for Ansible Installation

1. **Check Ansible Version**:
```bash
ansible --version
```

2. **If Not Installed**:
```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install ansible

# On Windows
pip install ansible

# Verify installation
ansible --version
```

## What to Automate vs. What to Do Once

### Automate These (Version Controlled)

1. **Infrastructure Setup**:
   - ✅ Kubernetes manifests (deployments, services)
   - ✅ Helm charts and values
   - ✅ ArgoCD configurations
   - ✅ Monitoring configurations (Prometheus, Grafana)

2. **Application Code**:
   - ✅ Source code
   - ✅ Dockerfiles
   - ✅ CI/CD pipelines
   - ✅ Test suites

3. **Configuration**:
   - ✅ Environment variables (structure, not values)
   - ✅ Application settings
   - ✅ Service dependencies

4. **Documentation**:
   - ✅ README files
   - ✅ API documentation
   - ✅ Architecture diagrams
   - ✅ Runbooks

### One-Time Setup (Not Version Controlled)

1. **Security Credentials**:
   - ❌ API keys
   - ❌ Passwords
   - ❌ SSL certificates
   - ❌ SSH keys

2. **Environment-Specific**:
   - ❌ IP addresses
   - ❌ Domain names
   - ❌ Environment variables (actual values)
   - ❌ Cloud provider credentials

3. **Personal Settings**:
   - ❌ IDE configurations
   - ❌ Local development settings
   - ❌ Personal scripts

## Our Project Structure

```
migrate_cloud/
├── .github/
│   └── workflows/          # CI/CD pipelines (Automate)
├── k8s/
│   ├── applications/      # ArgoCD app definitions (Automate)
│   ├── monitoring/        # Monitoring configs (Automate)
│   └── on-premise/        # K8s manifests (Automate)
├── ansible/
│   ├── inventory.yaml     # Server details (Template: Yes, Values: No)
│   └── helm-install.yaml  # Helm installation (Automate)
├── docs/                  # Documentation (Automate)
└── .gitignore            # Git exclusions (Automate)
```

## What We've Automated

1. **Infrastructure Deployment**:
   ```bash
   # Automated via ArgoCD
   kubectl apply -f k8s/applications/
   ```

2. **Monitoring Setup**:
   ```bash
   # Automated via Ansible
   ansible-playbook -i ansible/inventory.yaml ansible/helm-install.yaml
   ```

3. **Application Deployment**:
   ```bash
   # Automated via GitHub Actions + ArgoCD
   git push  # Triggers CI/CD pipeline
   ```

## What We Did Once

1. **Initial Setup**:
   - Setting up GitHub repository
   - Creating GitHub tokens
   - Setting up SSH keys

2. **Environment Configuration**:
   - Configuring DNS
   - Setting up initial cluster
   - Creating initial secrets

3. **Local Development**:
   - Installing development tools
   - Setting up IDE
   - Configuring local environment

## Best Practices

1. **Version Control**:
   - Keep infrastructure as code
   - Use meaningful commit messages
   - Branch for features/changes

2. **Security**:
   - Never commit secrets
   - Use secret management
   - Rotate credentials regularly

3. **Documentation**:
   - Document manual steps
   - Keep README updated
   - Include troubleshooting guides

4. **Testing**:
   - Test automation scripts
   - Validate configurations
   - Use staging environment

## Checklist for New Changes

1. **Should be Automated If**:
   - Needs to be repeated
   - Part of deployment process
   - Required for scaling
   - Critical for consistency

2. **Should be Manual If**:
   - One-time setup
   - Contains sensitive data
   - Environment-specific
   - Personal preference

## Tools Used in Our Setup

1. **Automation Tools**:
   - Ansible (Infrastructure automation)
   - ArgoCD (Continuous Delivery)
   - GitHub Actions (CI/CD)

2. **Infrastructure**:
   - Kubernetes (Container orchestration)
   - Helm (Package management)
   - Prometheus/Grafana (Monitoring)

3. **Version Control**:
   - Git
   - GitHub

## Troubleshooting

1. **Ansible Issues**:
```bash
# Check Ansible version
ansible --version

# Test connection
ansible all -i inventory.yaml -m ping

# Debug playbook
ansible-playbook -i inventory.yaml playbook.yaml -vvv
```

2. **Kubernetes Issues**:
```bash
# Check cluster status
kubectl cluster-info

# View logs
kubectl logs -n <namespace> <pod-name>
```

3. **ArgoCD Issues**:
```bash
# Check app status
argocd app get <app-name>

# Sync app
argocd app sync <app-name>
```
