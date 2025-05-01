# TechOps EKS Hello World

This project provisions an AWS EKS cluster using Terraform and deploys a simple "Hello World" Flask application using Helm via GitHub Actions.

---

## Prerequisites

Before using this project, make sure you have the following:

### AWS Setup

1. **Create an account in AWS**
2. **Configure AWS CLI** locally with the root user first to create resources (create access_id and secret_key before running the next command):
   ```sh
   aws configure --profile root
   ```

### Local Dependencies

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Docker (to build and push the image)

---

## GitHub Repository Configuration

### GitHub Secrets

In your repository go to **Settings > Secrets and Variables > Actions**, and add:

#### Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

#### Variables:
- `ECR_REPO` — e.g., `vo/hello_world`
- `AWS_REGION` — e.g., `eu-west-1`
- `CLUSTER_NAME` — e.g., `hello-eks-cluster`

---

## Infrastructure Provisioning with Terraform

### 1. Clone the repository

```bash
git clone https://github.com/drama17/techops.git
cd techops
```

### 2. Create an admin user and an s3 bucket for storing the state file

Comment in the file terraform/backend.tf first section:
```
terraform {
  backend "s3" {
    bucket  = "hw-s3-tfstate"
    key     = "terraform/foobar.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
```
Then run commands:
```bash
cd terraform
terraform init
terraform plan
terraform apply -target aws_s3_bucket_server_side_encryption_configuration.tf_state -target aws_s3_bucket_versioning.tf_state \
-target aws_s3_bucket.tf_state -target aws_iam_user.aws_admin -target aws_iam_user_policy.aws_admin_policy -target aws_iam_access_key.aws_admin
```

### 3. **Switch to the `aws-admin` profile** after the user is created and backend is set up:
```sh
aws configure --profile aws-admin
```
**NOTE:** There are two ways to get credentials for `aws-admin` and `github-actions` users:
  1) Change `true` to `false` for option `sensitive` in terraform/ouputs.tf file for these users
  2) Run commands
  ```bash
  terraform output -raw aws_access_admin_key_id
  terraform output -raw aws_secret_access_admin_key
  ```

### 4. Backend Configuration

Uncomment the `backend "s3"` block in `main.tf`, then:

```bash
terraform init -backend-config="profile=aws-admin"
terraform apply
```

This will create:
- VPC with private/public subnets
- EKS cluster
- ECR repository

### Access to EKS cluster

Run command to generate kubeconfig file and check access and create namespace:
```bash
aws eks --region eu-west-1 update-kubeconfig --name hello-eks-cluster
kubectl get nodes
kubectl create ns dev
```

---

## Build and Push Docker Image (locally) - testing purpose

```bash
docker build -t hello_world .
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <your-account>.dkr.ecr.eu-west-1.amazonaws.com
docker tag hello_world <your-repo-uri>:<tag>
docker push <your-repo-uri>:<tag>
```

---

## CI/CD via GitHub Actions

### Automatic Deployment

Push to the `master` branch triggers GitHub Actions, which:

- Builds and pushes Docker image to ECR
- Deploys app to EKS using Helm

### Manual Deployment (Optional)

```bash
helm upgrade --install hello-app ./helm-chart   --namespace dev  --set image.repository=<your-repo-uri>   --set image.tag=<tag>
```

---

## Access the Application

Check service external IP:

```bash
kubectl get svc hello-app -n dev
```

Open in browser:

```
http://<external-ip>
```

---

## Reflection

This solution demonstrates an automated DevOps pipeline integrating Terraform, AWS EKS, Helm, and GitHub Actions. 
Key challenges included setting up the correct IAM permissions for GitHub Actions and configuring EKS access entries. 
With more time, enhancements would include:
 - logging/monitoring (e.g., Prometheus/Grafana+ELK)
 - using IRSA and Vault for secrets
 - optimizing cost by scaling node groups, using saving plans
 - creating DNS record for fine access
 - adding CDN provider for better performance, redusing costs and better defense from DDOS and etc.

---
