# AI Inference Platform 🚀

A cloud-native AI inference platform built using FastAPI, HuggingFace Transformers, Docker, and Kubernetes.

This project serves a lightweight LLM (distilgpt2) through a REST API and deploys it as a containerized workload inside Kubernetes.

---

# 📌 Features
- FastAPI-based AI inference API
- HuggingFace Transformers integration
- Dockerized application
- Kubernetes Deployment & Service
- Resource requests/limits configuration
- Local Kubernetes deployment using Docker Desktop
- AI workload stabilization & OOM debugging
- REST endpoint for text generation

---

# 🏗 Architecture

Client
   ↓
FastAPI API
   ↓
Transformers Pipeline
   ↓
distilgpt2 Model
   ↓
Docker Container
   ↓
Kubernetes Pod

---

# 📂 Project Structure

ai-inference-platform/
│
├── app/
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── venv/
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── terraform/
├── helm/
├── .github/workflows/
└── README.md

---

# 🚀 Setup Guide

# 1️⃣ Clone Repository

git clone https://github.com/ShashiKaran-git/kubernetes-ai-inference-platform.git

cd kubernetes-ai-inference-platform

# 2️⃣ Create Virtual Environment

cd app

python -m venv venv

Activate venv (Git Bash)

source venv/Scripts/activate

# 3️⃣ Install Dependencies

pip install -r requirements.txt

# 4️⃣ Run FastAPI Locally

uvicorn main:app --reload

Open:

http://127.0.0.1:8000/docs

# 🐳 Docker Setup

# 5️⃣ Build Docker Image

Inside app/:

docker build -t ai-inference-api .

# 6️⃣ Run Docker Container

docker run -p 8000:8000 ai-inference-api

Open:

http://localhost:8000/docs

# ☸ Kubernetes Deployment

# 7️⃣ Enable Kubernetes in Docker Desktop

Open Docker Desktop

Enable Kubernetes

Wait until Kubernetes status becomes "Running"

# 8️⃣ Verify Cluster

kubectl get nodes

# 9️⃣ Deploy Application

From project root:

kubectl apply -f k8s/deployment.yaml

kubectl apply -f k8s/service.yaml

# 🔟 Verify Pods

kubectl get pods

# 1️⃣1️⃣ Port Forward Service

kubectl port-forward service/ai-inference-service 8000:80

Open:

http://localhost:8000/docs

---

# 📡 API Endpoint

POST /generate

Example Request:

{
  "prompt": "Explain Kubernetes"
}

# Example Response:

{
  "response": "Kubernetes is an open-source container orchestration platform..."
}

---

# 🛠 Tech Stack

- Python
- FastAPI
- HuggingFace Transformers
- PyTorch
- Docker
- Kubernetes
- Docker Desktop Kubernetes
- YAML

---

# ⚠️ Challenges Faced

- Kubernetes CrashLoopBackOff
- AI container OOMKilled
- WSL2 memory limitations
- Resource tuning for AI workloads
- Docker Desktop Kubernetes stabilization
- PyTorch dependency issues inside containers

---

# 🧠 Key Learnings

- AI workloads consume significantly more memory than traditional microservices
- Kubernetes resource requests/limits are critical for workload stability
- Container orchestration introduces new debugging challenges
Docker Desktop + WSL2 memory tuning impacts Kubernetes workloads

---

# 🔮 Future Improvements

- Horizontal Pod Autoscaler (HPA)
- Helm charts
- GitHub Actions CI/CD
- Prometheus & Grafana monitoring
- AWS EKS deployment
- ArgoCD GitOps
- GPU inference support
- vLLM integration

---

# 👨‍💻 Author

Shashi Karan
LinkedIn:

https://www.linkedin.com/in/shashikaran