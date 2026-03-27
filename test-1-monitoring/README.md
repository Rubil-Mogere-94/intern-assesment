# Test 1 – Monitoring Stack

## Tool Selection & Justification

### Logging tools: Loki + Promtail + Grafana

- **Loki** – lightweight, cost‑effective, integrates natively with Grafana, stores logs in a way that matches Prometheus labels, perfect for Kubernetes.
- **Promtail** – DaemonSet that scrapes container logs and pushes them to Loki; easy to configure and low resource overhead.
- **Why not ELK?** ELK (Elasticsearch, Logstash, Kibana) is more powerful but heavier to run and maintain. Loki/Promtail align better with the “Kubernetes native” philosophy and are simpler for a small team.

### Metrics tools: Prometheus + Grafana

- **Prometheus** – de facto standard for Kubernetes metrics, excellent service discovery, powerful query language (PromQL).
- **Grafana** – unified dashboard for both metrics and logs, rich ecosystem of pre‑built dashboards, easy to share.
- **Azure Monitor** could be used, but it’s less flexible and vendor‑locked. Prometheus/Grafana give us portability and are widely adopted.

## Environment Used

I deployed the stack on a **local kind (Kubernetes in Docker)** cluster to keep it self‑contained and cost‑free.  
The same manifests would work on AKS with minimal changes (e.g., use Azure storage for Loki persistence).

## Setup Steps

### 1. Create a kind cluster
```bash
kind create cluster --name monitoring-demo
```

### 2. Install the monitoring stack using Helm

```bash
# Add repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus (with Grafana as part of kube-prometheus-stack)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f config/prometheus-values.yaml

# Install Loki
helm install loki grafana/loki-stack \
  --namespace monitoring \
  -f config/loki-values.yaml \
  --set promtail.enabled=false   # we install Promtail separately

# Install Promtail as a DaemonSet
helm install promtail grafana/promtail \
  --namespace monitoring \
  -f config/promtail-values.yaml
```

### 3. Port‑forward Grafana and access it
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
Open http://localhost:3000 (default credentials: admin/prom-operator).

### 4. Verify logs in Grafana
- Add Loki as a data source (URL: `http://loki:3100`).
- Go to Explore, select Loki, and see container logs.

### 5. Verify metrics
- Prometheus is already a data source.
- Go to the “Kubernetes / Compute Resources / Cluster” dashboard to see CPU, memory, pod count.

## Dashboards & Alerts

### Metrics Dashboard
I created a custom dashboard (`dashboards/kubernetes-metrics-dashboard.json`) that focuses on:

- **Cluster overview** – CPU / memory usage, pod count, node health.
- **Pod details** – per‑pod CPU/memory, restarts, status.
- **Network** – ingress/egress traffic per pod.

### Logs Dashboard
A simple dashboard (`dashboards/logs-dashboard.json`) that:
- Shows the top log producers.
- Provides a log viewer with label filters (namespace, pod, container).
- Includes a “last 15 minutes” log stream for quick debugging.

### Alerts
I defined the following alerts (`alerts/prometheus-alerts.yaml`):
- **HighPodRestarts**: alerts if a pod restarts more than 3 times in 10 minutes.
- **HighCPUUsage**: CPU > 80% for 5 minutes.
- **LowDiskSpace**: node disk usage > 85%.

Alertmanager configuration (`alerts/alertmanager-config.yaml`) routes alerts to a dummy webhook (in production this would be Slack, PagerDuty, etc.).
