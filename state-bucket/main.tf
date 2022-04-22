# Template for a terraform file
# creating an S3 bucket to hold state
provider "aws" {
}

resource "random_id" "terraform_state_id" {
  byte_length = 2
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "methos-tf-state-bucket-${random_id.terraform_state_id.dec}"
  tags = {
    Org = "methos"
    Team = "methos-admins"
    Name = "methos-tf-state-bucket-${random_id.terraform_state_id.dec}"
    Project = "Infrastructure"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "terrraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
