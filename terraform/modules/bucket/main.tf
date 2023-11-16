provider "aws"{
    region = "us-west-2"
}

resource "aws_s3_bucket" "terra-state"{
    bucket = "lock-state-for-terra"
    lifecycle {
     prevent_destroy = true
    }

    tags = {
        Name = "Terraform-lock-bucket"
    }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terra_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terra_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terra_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}