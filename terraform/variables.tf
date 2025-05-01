variable "eks_version" {
  default = "1.32"
}

variable "account_id" {
  description = "AWS account id"
  type        = string
  default = "521673981163"
}

variable "region" {
  description = "AWS region"
  type        = string
  default = "eu-west-1"
}

variable "zones" {
  description = "AWS zones"
  type        = set(string)
  default = ["eu-west-1-a", "eu-west-1-b"]
}

variable "s3_bucket" {
  description = "S3 bucket for storing Terraform state"
  type        = string
  default = "hw_s3"
}
