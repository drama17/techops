terraform {
  backend "s3" {
    bucket  = "hw-s3-tfstate"
    key     = "terraform/foobar.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = var.s3_bucket_tfstate
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-state"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = resource.aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = resource.aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
