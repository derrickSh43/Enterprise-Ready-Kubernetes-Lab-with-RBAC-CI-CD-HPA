# 🏗️ Enterprise-Ready Kubernetes Lab with RBAC, CI/CD, HPA, and Observability

This project is a full-stack, production-grade Kubernetes lab built on GKE and designed to simulate the infrastructure, security, and observability practices of real-world enterprise environments. It includes multiple namespaces, fine-grained RBAC, autoscaling, CI/CD pipelines, monitoring dashboards, and cost-aware node management — all configured using YAML, Helm, and Terraform.

---

## 📌 Key Features

| Category           | Tools / Technologies                                                                 |
|--------------------|---------------------------------------------------------------------------------------|
| **Platform**       | Google Kubernetes Engine (GKE), Terraform, Preemptible Nodes                          |
| **Apps Deployed**  | Sock Shop Microservices, WordPress + MySQL, NGINX, Echoserver                         |
| **CI/CD**          | Jenkins with Persistent Volume, GitHub Actions                                       |
| **Security**       | Network Policies, RBAC per namespace (dev, prod, monitoring)                          |
| **Monitoring**     | Prometheus, Grafana, kube-state-metrics, node-exporter                               |
| **Scaling**        | HPA for NGINX and Sock Shop, Cluster Autoscaler, Pod Disruption Budgets              |
| **Logging**        | GKE-native telemetry, optional FluentBit/ELK stack                                    |
| **Cost Awareness** | Preemptible node pools, resource limits, autoscaler + teardown logic                  |

---

## 🧱 Architecture Overview

![Architecture](images/sockshop.png) <!-- Update with a clearer arch diagram if available -->

- Namespaces: `dev`, `prod`, `monitoring`, `jenkins`
- Ingress: NGINX Ingress Controller + Load Balancer IP
- Storage: Persistent Volumes for Jenkins and WordPress
- Monitoring: Live dashboards (exported JSON), alerts, and metrics
- CI/CD: Jenkins pipelines + GitHub Actions deployment test
- Autoscaling: Configured HPA with load simulation via Locust

---

## 🧪 Testing & Workflows

| Test | Outcome |
|------|---------|
| 🔁 Pod scaling (CPU-based) | Verified with `stress-test` and HPA configs |
| 📈 Grafana dashboards | Confirmed for NGINX, Sock Shop, Node usage |
| 🔐 RBAC enforcement | Tested access per namespace role |
| ⚙️ CI/CD Pipeline | Validated Jenkins and GitHub Actions |
| 💾 WordPress failover | MySQL persistence verified |
| 🔄 Cluster teardown + rehydration | Terraform-based recreate + restore successful |

---

## 🧰 Local Dev / Alternative Environments

If GCP credits are unavailable:
- Use `kind` or `k3d` to simulate a smaller version locally
- Partial stack includes NGINX, echoserver, Prometheus, Grafana
- Configuration examples included in `/echoserver-lab/` and `/charts/`

---

## 📂 Repo Structure

