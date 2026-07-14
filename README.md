<div align="center">

# ☸️ Kubernetes AI Inference Platform

**A hands-on DevOps project deploying a FastAPI application on AWS EKS using a complete gitOps workflow.**

![Build](https://img.shields.io/github/actions/workflow/status/ShashiKaran-git/kubernetes-ai-inference-platform/docker-build.yaml?style=flat-square&label=CI%2FCD&color=22c55e)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Hub-2496ED?style=flat-square&logo=docker&logoColor=white)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-F46800?style=flat-square&logo=grafana&logoColor=white)

</div>

---

## 📌 Overview

This project provisions a cloud native infrastructure on **AWS EKS** and deploys a **FastAPI** application using a fully automated GitOps pipeline. Infrastructure is managed with **Terraform**, deployments are packaged with **Helm**, and **ArgoCD** keeps the cluster in sync with the Git repository - no manual `kubectl apply` required.

Built as a hands on project to learn how modern DevOps tooling works end-to-end — from `git push` to a running pod on Kubernetes.

Environment:
- AWS Region: ap-south-1
- EKS Version: 1.33
- Node Group: 2 × t3.small

---

## 🏗 Architecture

```
Developer
    │
    │  git push
    ▼
GitHub Repository
    │
    ├──► GitHub Actions
    │         │
    │         │  docker build + push
    │         ▼
    │      Docker hub
    │
    └──► ArgoCD (GitOps Controller)
              │
              │  detects Helm chart changes
              ▼
           Helm Chart
              │
              ▼
        Amazon EKS Cluster
              │
        ┌─────┴─────┐
        │           │
      Pod 1       Pod 2  ←── HPA (scales on CPU utilization)
        │           │
        └─────┬─────┘
              │                  Prometheus ──► Grafana
        Kubernetes Service       (scrapes pod metrics)
        (LoadBalancer)
              │
              ▼
            Users
```

---

## 📸 Screenshots

| ArgoCD Sync | GitHub Actions | EKS Nodes |
|:-----------:|:--------------:|:---------:|
| ![ArgoCD](docs/screenshots/argocd-sync.png) | ![Actions](docs/screenshots/github-actions-success.png) | ![Nodes](docs/screenshots/eks-nodes.png) |

| Running Pods | HPA Live Scaling | Grafana Monitoring |
|:------------:|:----------------:|:-----------------:|
| ![Pods](docs/screenshots/pods-running.png) | ![HPA](docs/screenshots/hpa.png) | ![Grafana](docs/screenshots/grafana-dashboard.png) |

---

## 🛠 Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Cloud** | AWS EKS, VPC, IAM, ELB | Managed Kubernetes cluster and networking |
| **IaC** | Terraform | Provision all AWS infrastructure declaratively |
| **Containers** | Docker, Docker Hub | Build and store application images |
| **Packaging** | Helm | Template and manage Kubernetes manifests |
| **GitOps** | ArgoCD | Automated, self-healing deployments from Git |
| **CI/CD** | GitHub Actions | Auto-build and push Docker images on push |
| **Autoscaling** | Kubernetes HPA | Scale pods based on CPU utilization |
| **Monitoring** | Prometheus, Grafana | Scrape and visualize pod and cluster metrics |
| **Application** | python, FastAPI | lightweight API server |

---

## 📂 Project Structure

```
kubernetes-ai-inference-platform/
│
├── app/                          # FastAPI application
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── terraform/                    # AWS infrastructure (EKS, VPC, IAM)
│   ├── provider.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── ai-inference-chart/           # Helm chart for Kubernetes deployment
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── hpa.yaml
│   ├── chart.yaml
│   └── values.yaml
│
├── .github/workflows/
│   └── docker-build.yaml         # GitHub Actions CI pipeline
│
└── README.md
```

---

## 🚀 Deployment Workflow

The project follows a structured deployment process across four stages:

### 1 · Provision Infrastructure

Terraform provisions the full AWS environment — VPC with public/private subnets, an EKS cluster, and a managed node group.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2 · Connect to the cluster

```bash
aws eks update-kubeconfig --region ap-south-1 --name ai-inference-cluster
kubectl get nodes
```

### 3 · Deploy the application via Helm

```bash
helm upgrade --install ai-inference ./ai-inference-chart
kubectl get pods
kubectl get svc
```

### 4 · Install ArgoCD & Enable Gitops

```bash
kubectl create namespace argocd
kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose the ArgoCD UI
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'

# Retrieve admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Once ArgoCD is connected to the repository, all future deployments happen automatically on `git push`.

---

## 📊 Monitoring

Prometheus and Grafana were deployed to the cluster to observe real-time pod and resource metrics.

- Prometheus scrapes metrics from the running pods in the `default` namespace
- Grafana dashboards show **Memory Usage (WSS)**, memory requests vs limits, and CPU utilization per pod
- Verified live: pod `ai-inference-api` showed memory request of **512 MiB** against a 1 GiB limit

---

## ⚡ Horizontal pod autoscaling

HPA is configured to scale the deployment between **1 and 3 replicas** based on CPU utilization (target: 5%).

Verified live - CPU spiked to **67%**, triggering HPA to scale replicas from 1 → 3 automatically:

```
NAME               REFERENCE                        TARGETS     MINPODS   MAXPODS   REPLICAS
ai-inference-hpa   Deployment/ai-inference-api      67%/5%      1         3         3
```

---

## 🔄 GitOps Workflow

### GitOps validation

1. Updated replicaCount from 1 to 2 in values.yaml
2. Committed and pushed the change to GitHub
3. GitHub Actions built and pushed the updated image
4. ArgoCD detected the repository change automatically
5. Deployment synchronized without running kubectl apply
6. Verified the new replica count using kubectl get pods

---

## 🚨 Challenges & solutions

Real issues encountered during the build — and how they were fixed.

| # | Problem | Root cause | Fix |
|---|---------|-----------|-----|
| 1 | `You must be logged in to the server` | IAM user not mapped to EKS cluster | Configured EKS Access Entries and associated the `AmazonEKSClusterAdminPolicy` to the IAM user. |
| 2 | `ImagePullBackOff` on pods | Wrong Docker image path in `values.yaml` | Corrected `image.repository` to match the exact Docker Hub image name |
| 3 | ArgoCD controller `CrashLoopBackOff` | Incomplete CRD installation from partial install | Deleted the namespace, removed stale CRDs, and performed a clean reinstall |
| 4 | `0/1 nodes available: Too many pods` | Single-node cluster exceeded pod capacity | Scaled the EKS managed node group from 1 → 2 nodes via Terraform |

---

## 🎓 Key Learnings

- **Terraform** - Writing modular IaC to manage VPC, EKS, and IAM from scratch
- **EKS** - Understanding managed node groups, access entries, and kubeconfig setup
- **Helm** - Templating Kubernetes manifests and managing releases with `upgrade --install`
- **ArgoCD** - Connecting a Git repository to a live cluster and configuring self-healing sync
- **GitOps** - The value of declarative config: changing a value in Git is the deployment
- **HPA** - Watching CPU-triggered autoscaling happen live in real time
- **Monitoring** - Deploying Prometheus + Grafana and reading real pod memory and CPU metrics
- **Debugging** - Reading pod events (`kubectl describe pod`) and logs to trace real errors

---

## 📈 Future Improvements

- [ ] **AWS ALB Ingress Controller** - Replace LoadBalancer service with ALB for path-based routing
- [ ] **Centralized Logging** - EFK stack for log aggregation across pods
- [ ] **Terraform Remote State** - S3 + DynamoDB backend for safe team collaboration
- [ ] **TLS / HTTPS** - Automate certificates with cert-manager and Let's Encrypt
- [ ] **ArgoCD Rollouts** - Blue/green or canary deployments for zero-downtime releases

---

## 👤 Author

**Shashi Karthikeya**
Aspiring DevOps Engineer - learning by building real projects.

[![GitHub](https://img.shields.io/badge/GitHub-ShashiKaran--git-181717?style=flat-square&logo=github)](https://github.com/ShashiKaran-git)

---

<div align="center">
  <sub>Built with curiosity, debugged with patience.</sub>
</div>

---
