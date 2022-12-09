terraform {
  backend "s3" {
    bucket = "s3-bucket-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}


provider "aws" {
  region = "eu-west-3"
}
//TODO: add s3 as a backend
//investigate how to revert broken state file on s3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "s3-bucket-state"
  lifecycle {
    prevent_destroy = true
  }
  
  
}
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
    
}
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}