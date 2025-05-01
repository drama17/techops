output "current_time" {
  value = time_static.current.rfc3339
}

output "eks_access-entries" {
  value = module.eks.access_entries
}

output "ecr_repository_url" {
  value = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.hello_world.name}"
}
