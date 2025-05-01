module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"
  name    = "eks-vpc"
  cidr    = "10.0.0.0/16"
  azs     = var.zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "hello-eks-cluster"
  cluster_version = var.eks_version
  subnet_ids      = module.vpc.public_subnets.subnet_ids
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t2.micro"]
    }
  }
}

resource "aws_ecr_repository" "hello_world" {
  name = "vo/hello_world"

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "hello_world"
    Environment = "dev"
  }
}

resource "time_static" "current" {}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "default"

  set {
    name  = "server.dev.enabled"
    value = "true"
  }

  set {
    name  = "injector.enabled"
    value = "true"
  }
}
