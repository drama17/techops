module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/hello-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/hello-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/hello-eks-cluster" = "shared"
  }
}

data "http" "vo_ip" {
  url = "https://checkip.amazonaws.com/"
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "hello-eks-cluster"
  cluster_version = var.eks_version
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
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }

  depends_on = [module.eks]
}
