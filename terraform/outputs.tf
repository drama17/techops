output "ecr_repository_url" {
  description = "ECR repo url"
  value       = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.hello_world.name}"
}

output "aws_access_admin_key_id" {
  value       = aws_iam_access_key.aws_admin.id
  description = "Use this as admin AWS_ACCESS_KEY_ID"
  sensitive   = true
}

output "aws_secret_access_admin_key" {
  value       = aws_iam_access_key.aws_admin.secret
  description = "Use this as admin AWS_SECRET_ACCESS_KEY"
  sensitive   = true
}

output "aws_access_github_key_id" {
  value       = aws_iam_access_key.github_actions.id
  description = "Use this as github AWS_ACCESS_KEY_ID"
  sensitive   = true
}

output "aws_secret_access_github_key" {
  value       = aws_iam_access_key.github_actions.secret
  description = "Use this as github AWS_SECRET_ACCESS_KEY"
  sensitive   = true
}

output "my_ip" {
  value = chomp(data.http.vo_ip.response_body)
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
