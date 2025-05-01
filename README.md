# Hello World EKS App

## 🛠️ Prerequisites
- AWS Account + CLI configured
- AWS IAM user with EKS, ECR, VPC privileges
- Terraform, Helm, kubectl installed
- GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## 📦 Infrastructure Provisioning
```bash
cd terraform
terraform init
terraform apply
```

## 🚀 CI/CD Pipeline
Push to `main` – GitHub Actions will build & deploy automatically.

## 🌐 Accessing the App
After deployment, get the LoadBalancer URL:
```bash
kubectl get svc
```

## 💬 Reflection
This project demonstrates full-cycle DevOps: app -> Docker -> EKS -> Helm -> CI/CD. I chose Terraform modules to accelerate provisioning and Helm for reusable deployments. Future improvements: Prometheus, cert-manager, autoscaling, cost optimizations.
