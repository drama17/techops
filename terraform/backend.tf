terraform {
  backend "s3" {
    bucket         = resource.aws_s3_bucket.name
    region         = var.region
    encrypt        = true
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.s3_bucket
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-state"
    Environment = "dev"
  }
}
