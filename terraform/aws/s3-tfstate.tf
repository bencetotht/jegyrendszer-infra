# S3 Bucket
resource "aws_s3_bucket" "state-bucket" {
  bucket = "bnbdevelopment-tfstate-bucket"

  tags = {
    Name        = "bnbdevelopment-tfstate-bucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket_ownership_controls" "state-bucket" {
  bucket = aws_s3_bucket.state-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "state-bucket" {
  bucket                  = aws_s3_bucket.state-bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "state-bucket" {
  bucket = aws_s3_bucket.state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state-bucket" {
  bucket = aws_s3_bucket.state-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Config
data "aws_iam_user" "terraform-admin" {
  user_name = "terraform"
}

# IAM Policy
resource "aws_iam_policy" "state-bucket-admin" {
  name        = "TerraformStateAdminPolicy"
  description = "Allow Terraform admins to manage Terraform state bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.state-bucket.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.state-bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "state-bucket-admin-attach" {
  user       = data.aws_iam_user.terraform-admin.user_name
  policy_arn = aws_iam_policy.state-bucket-admin.arn
}

output "state-bucket" {
  value = aws_s3_bucket.state-bucket.bucket
}