variable "account_id" {
  description = "AWS account id"
  type        = string
  default     = "521673981163"
}
variable "s3_bucket_tfstate" {
  description = "S3 bucket for storing Terraform state"
  type        = string
  default     = "hw-s3-tfstate"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "techops"
}
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.32"
}
variable "node_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}
variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 3
}
variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 1
}
variable "node_disk_size" {
  description = "Disk size for the EKS nodes in GB"
  type        = number
  default     = 10
}
