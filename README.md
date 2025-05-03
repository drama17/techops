# TechOps EKS Hello World

This project provisions an AWS EKS cluster using Terraform and deploys a simple "Hello World" Flask application using Helm via GitHub Actions.

---

## 🚀 Prerequisites

Before using this project, make sure you have the following:

### ✅ AWS Setup

1. **Create an S3 bucket** for Terraform backend manually in AWS console or CLI.
2. **Create an IAM admin user** (e.g., `aws-admin`) with full permissions. Save their access keys.
3. **Configure AWS CLI** locally with the root user first to create resources:
   ```sh
   aws configure --profile root
   ```
4. **Switch to the `aws-admin` profile** after the user is created and backend is set up:
   ```sh
   aws configure --profile aws-admin
   ```

### ✅ Local Dependencies

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Docker (to build and push the image)

---

## 📦 GitHub Repository Configuration

### 🔒 GitHub Secrets

In your repository go to **Settings > Secrets and Variables > Actions**, and add:

#### Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

#### Variables:
- `ECR_REPO` — e.g., `vo/hello_world`
- `AWS_REGION` — e.g., `eu-west-1`
- `CLUSTER_NAME` — e.g., `hello-eks-cluster`

---

## ⚙️ Infrastructure Provisioning with Terraform

### 1. Clone and Set Up

```bash
git clone https://github.com/drama17/techops.git
cd techops
```

### 2. Backend Configuration

Uncomment the `backend "s3"` block in `main.tf`, then:

```bash
terraform init -backend-config="profile=aws-admin"
terraform apply
```

This will create:
- VPC with private/public subnets
- EKS cluster
- ECR repository

---

## 🐳 Build and Push Docker Image

```bash
docker build -t hello_world .
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <your-account>.dkr.ecr.eu-west-1.amazonaws.com
docker tag hello_world <your-repo-uri>
docker push <your-repo-uri>
```

---

## ⚡ CI/CD via GitHub Actions

### Automatic Deployment

Push to the `main` branch triggers GitHub Actions, which:

- Builds and pushes Docker image to ECR
- Deploys app to EKS using Helm

### Manual Deployment (Optional)

```bash
helm upgrade --install hello-app ./helm-chart   --namespace dev   --create-namespace   --set image.repository=<your-repo-uri>   --set image.tag=<tag>
```

---

## 🌍 Access the Application

Check service external IP:

```bash
kubectl get svc -n dev
```

Open in browser:

```
http://<external-ip>
```

---

## 💬 Reflection

This solution demonstrates an automated DevOps pipeline integrating Terraform, AWS EKS, Helm, and GitHub Actions. Key challenges included setting up the correct IAM permissions for GitHub Actions and configuring EKS access entries. With more time, enhancements would include logging/monitoring (e.g., Prometheus/Grafana), using IRSA and Vault for secrets, and optimizing cost by scaling node groups.

---
