# IAM Root User
data "aws_iam_user" "adminuser_policies" {
  user_name = "bencetoth"
}

# S3 Bucket
resource "aws_s3_bucket" "policies" {
  bucket = "bnbdevelopment-policies"

  tags = {
    Name        = "bnbdevelopment-policies"
    Environment = "production"
  }
}

resource "aws_s3_bucket_ownership_controls" "policies" {
  bucket = aws_s3_bucket.policies.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "policies" {
  bucket                  = aws_s3_bucket.policies.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# Enable versioning
resource "aws_s3_bucket_versioning" "policies" {
  bucket = aws_s3_bucket.policies.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle configuration to move old versions to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "policies" {
  bucket = aws_s3_bucket.policies.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER_IR"
    }
  }
}

# CloudFront Origin Access Identity (OAI)
resource "aws_cloudfront_origin_access_identity" "policies" {
  comment = "Access identity for policies bucket"
}

# Bucket Policy
resource "aws_s3_bucket_policy" "policies" {
  bucket = aws_s3_bucket.policies.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.policies.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.policies.arn}/*"
      },
      {
        Sid       = "ExplicitlyDenyList"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.policies.arn
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = [
              data.aws_iam_user.adminuser_policies.arn,
              aws_iam_user.policies-uploader.arn
            ]
          }
        }
      },
      {
        Sid    = "AllowAdminList"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_user.adminuser_policies.arn
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.policies.arn
      }
    ]
  })
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "policies" {
  enabled             = true
  default_root_object = ""

  origin {
    domain_name = aws_s3_bucket.policies.bucket_regional_domain_name
    origin_id   = "s3-policies"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.policies.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-policies"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Cache PDFs for a longer period
    min_ttl     = 0
    default_ttl = 86400   # 1 day
    max_ttl     = 31536000 # 1 year
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
}

# IAM User for uploading policies
resource "aws_iam_user" "policies-uploader" {
  name = "policies-uploader"
}

resource "aws_iam_user_policy" "policies-uploader" {
  name = "policies-uploader-policy"
  user = aws_iam_user.policies-uploader.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.policies.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.policies.arn}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "policies-uploader" {
  user = aws_iam_user.policies-uploader.name
}

# Outputs
output "policies-bucket-name" {
  value = aws_s3_bucket.policies.bucket
}

output "policies-cloudfront-domain" {
  value = aws_cloudfront_distribution.policies.domain_name
}

output "policies-uploader-access-key-id" {
  value = aws_iam_access_key.policies-uploader.id
}

output "policies-uploader-secret-access-key" {
  value     = aws_iam_access_key.policies-uploader.secret
  sensitive = true
}
