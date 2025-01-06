# Kubernetes Monitoring Setup Guide

This guide covers the setup and configuration of monitoring using kube-prometheus-stack.

## Prerequisites

1. **Helm Installation**:
```bash
# Download Helm script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Make script executable
chmod 700 get_helm.sh

# Run script
./get_helm.sh
```

## Installing kube-prometheus-stack

1. **Add Helm Repository**:
```bash
# Add prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repo
helm repo update
```

2. **Create Monitoring Namespace**:
```bash
kubectl create namespace monitoring
```

3. **Install kube-prometheus-stack**:
```bash
# Basic installation
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Or with custom values (recommended)
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f monitoring-values.yaml
```

## Custom Values Configuration

Create `monitoring-values.yaml`:
```yaml
grafana:
  adminPassword: your-secure-password  # Change this
  service:
    type: NodePort
    nodePort: 30900  # Grafana UI

prometheus:
  service:
    type: NodePort
    nodePort: 30901  # Prometheus UI

alertmanager:
  service:
    type: NodePort
    nodePort: 30902  # Alertmanager UI

# Resource limits for production
prometheusOperator:
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

prometheus:
  prometheusSpec:
    retention: 15d  # Data retention period
    resources:
      limits:
        cpu: 1
        memory: 2Gi
      requests:
        cpu: 500m
        memory: 1Gi

grafana:
  resources:
    limits:
      cpu: 300m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi
```

## Accessing Monitoring Tools

1. **Using NodePort (recommended for MicroK8s)**:
```bash
# Get node IP
kubectl get nodes -o wide

# Access UIs at:
Grafana:     http://<node-ip>:30900
Prometheus:  http://<node-ip>:30901
Alertmanager: http://<node-ip>:30902
```

2. **Using Port-Forward (alternative)**:
```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090

# Alertmanager
kubectl port-forward -n monitoring svc/prometheus-alertmanager 9093:9093
```

## Important Dashboards

1. **Node Exporter Dashboard** (ID: 1860):
   - Hardware resource usage
   - System metrics
   - Network statistics

2. **Kubernetes Cluster** (ID: 315):
   - Cluster overview
   - Node status
   - Pod resources

3. **MongoDB** (ID: 2583):
   - Database metrics
   - Query performance
   - Connection stats

## Setting Up Custom Dashboards

1. **Application Dashboard**:
```json
{
  "dashboard": {
    "title": "E-commerce Metrics",
    "panels": [
      {
        "title": "API Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{app=\"backend\"}[5m])) by (le))"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m]))"
          }
        ]
      }
    ]
  }
}
```

## Resource Monitoring for Cloud Planning

1. **Key Metrics to Monitor**:
   - CPU Usage: `container_cpu_usage_seconds_total{namespace="default"}`
   - Memory Usage: `container_memory_usage_bytes{namespace="default"}`
   - Network I/O: `container_network_transmit_bytes_total`
   - Storage: `kubelet_volume_stats_used_bytes`

2. **Resource Planning Queries**:
```promql
# 95th percentile CPU usage by pod
histogram_quantile(0.95, sum(rate(container_cpu_usage_seconds_total{namespace="default"}[24h])) by (pod, le))

# Average memory usage by deployment
avg_over_time(container_memory_usage_bytes{namespace="default"}[7d])

# Peak network usage
max_over_time(container_network_transmit_bytes_total{namespace="default"}[30d])
```

## Alerting Rules

1. **High Resource Usage**:
```yaml
groups:
- name: resource-alerts
  rules:
  - alert: HighCPUUsage
    expr: container_cpu_usage_seconds_total > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      description: "Container {{ $labels.container }} CPU usage above 80%"

  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes > 0.85 * container_spec_memory_limit_bytes
    for: 5m
    labels:
      severity: warning
    annotations:
      description: "Container {{ $labels.container }} memory usage above 85%"
```

## Cloud Migration Planning

1. **Resource Requirements Calculation**:
```bash
# Get average resource usage
kubectl top pods --containers

# Export detailed metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods | jq .
```

2. **Sizing Guidelines**:
   - Add 20% buffer to peak CPU usage
   - Add 30% buffer to peak memory usage
   - Consider burst patterns in workload
   - Account for high availability requirements

## Troubleshooting

1. **Common Issues**:
```bash
# Check pod status
kubectl get pods -n monitoring

# View pod logs
kubectl logs -n monitoring pod/prometheus-operator-xyz

# Check configuration
kubectl describe configmap -n monitoring prometheus-config
```

2. **Metric Collection Issues**:
```bash
# Verify service discovery
kubectl port-forward -n monitoring svc/prometheus-prometheus 9090:9090
# Visit http://localhost:9090/targets
```

## Best Practices

1. **Resource Management**:
   - Set appropriate resource limits
   - Use horizontal pod autoscaling
   - Monitor resource trends

2. **Data Retention**:
   - Configure appropriate retention periods
   - Consider storage requirements
   - Plan for data backup

3. **Security**:
   - Change default passwords
   - Use RBAC for access control
   - Enable TLS where possible
