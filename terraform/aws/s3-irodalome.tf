# # IAM Root User
# data "aws_iam_user" "adminuser" {
#   user_name = "bencetoth"
# }

# # S3 Bucket
# resource "aws_s3_bucket" "irodalome-uploads" {
#   bucket = "irodalome-uploads-bucket"

#   tags = {
#     Name = "irodalome-uploads-bucket"
#     Environment = "production"
#   }
# }
# resource "aws_s3_bucket_ownership_controls" "irodalome-uploads" {
#   bucket = aws_s3_bucket.irodalome-uploads.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "irodalome-uploads" {
#   bucket = aws_s3_bucket.irodalome-uploads.id
#   block_public_acls = true
#   ignore_public_acls = true
#   block_public_policy = false
#   restrict_public_buckets = false
# }

# # CloudFront Origin Access Identity (OAI)
# resource "aws_cloudfront_origin_access_identity" "irodalome-uploads" {
#   comment = "Access identity for irodalome-uploads bucket"
# }

# # Bucket Policy
# resource "aws_s3_bucket_policy" "irodalome-uploads" {
#   bucket = aws_s3_bucket.irodalome-uploads.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowCloudFrontRead"
#         Effect = "Allow"
#         Principal = {
#           AWS = aws_cloudfront_origin_access_identity.irodalome-uploads.iam_arn
#         }
#         Action   = "s3:GetObject"
#         Resource = "${aws_s3_bucket.irodalome-uploads.arn}/*"
#       },
#       {
#         Sid       = "ExplicitlyDenyList"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:ListBucket"
#         Resource  = aws_s3_bucket.irodalome-uploads.arn
#       },
#       {
#         Sid = "AllowAdminList",
#         Effect = "Allow",
#         Principal = {
#           AWS = data.aws_iam_user.adminuser.arn
#         },
#         Action = "s3:ListBucket",
#         Resource = aws_s3_bucket.irodalome-uploads.arn
#       }
#     ]
#   })
# }

# # CloudFront Distribution
# resource "aws_cloudfront_distribution" "irodalome-uploads" {
#   enabled             = true
#   default_root_object = ""

#   origin {
#     domain_name = aws_s3_bucket.irodalome-uploads.bucket_regional_domain_name
#     origin_id   = "s3-irodalome-uploads"

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.irodalome-uploads.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "s3-irodalome-uploads"

#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   price_class = "PriceClass_100"
# }

# # IAM User
# resource "aws_iam_user" "irodalome-uploader" {
#   name = "irodalome-uploader"
# }

# resource "aws_iam_user_policy" "irodalome-uploader" {
#   name = "irodalome-uploader-policy"
#   user = aws_iam_user.irodalome-uploader.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:DeleteObject"
#         ]
#         Resource = "${aws_s3_bucket.irodalome-uploads.arn}/*"
#       }
#     ]
#   })
# }

# resource "aws_iam_access_key" "irodalome-uploader" {
#   user = aws_iam_user.irodalome-uploader.name
# }

# output "irodalome-bucket-name" {
#   value = aws_s3_bucket.irodalome-uploads.bucket
# }

# output "cloudfront_domain" {
#   value = aws_cloudfront_distribution.irodalome-uploads.domain_name
# }

# output "irodalome-uploader-access-key-id" {
#   value = aws_iam_access_key.irodalome-uploader.id
# }

# output "irodalome-uploader-secret-access-key" {
#   value = aws_iam_access_key.irodalome-uploader.secret
#   sensitive = true
# }