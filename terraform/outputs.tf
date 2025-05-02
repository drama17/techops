output "ecr_repository_url" {
  description = "ECR repo url"
  value       = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.hello_world.name}"
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
