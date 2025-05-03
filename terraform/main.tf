module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway     = var.environment != "production"
  one_nat_gateway_per_az = var.environment == "production"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                   = "1"
  }
}

data "http" "vo_ip" {
  url = "https://checkip.amazonaws.com/"
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  access_entries = {
    github-actions = {
      principal_arn     = "arn:aws:iam::521673981163:user/github-actions"
      kubernetes_groups = ["eks-admins"]
      policy_associations = {
        github-actions = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "namespace"
            namespaces = ["dev", "default"]
          }
        }
      }
    },
    admin-user = {
      principal_arn     = "arn:aws:iam::521673981163:user/aws-admin"
      kubernetes_groups = ["eks-admins"]
      policy_associations = {
        admin-user = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["${chomp(data.http.vo_ip.response_body)}/32","0.0.0.0/0"]
  eks_managed_node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t2.medium"]
    }
  }
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
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
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.hello_world.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
