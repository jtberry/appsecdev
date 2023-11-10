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