resource "aws_s3_bucket" "alb_access_logs" {  
  bucket = "s3-bucket-logs-test-one"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.alb_access_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::009996457667:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::s3-bucket-logs-test-one/alb/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.alb_access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.alb_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}
