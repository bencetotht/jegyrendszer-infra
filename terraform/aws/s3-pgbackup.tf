# S3 Bucket
resource "aws_s3_bucket" "pgbackup-bucket" {
  bucket = "bnbdevelopment-pgbackup-bucket"

  force_destroy = false

  tags = {
    Name        = "bnbdevelopment-pgbackup-bucket"
    Environment = "production"
  }

}

resource "aws_s3_bucket_ownership_controls" "pgbackup-bucket" {
  bucket = aws_s3_bucket.pgbackup-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pgbackup-bucket" {
  bucket                  = aws_s3_bucket.pgbackup-bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "pgbackup-bucket" {
  bucket = aws_s3_bucket.pgbackup-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "pgbackup-bucket" {
  bucket = aws_s3_bucket.pgbackup-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "pgbackup-bucket" {
  bucket = aws_s3_bucket.pgbackup-bucket.id

  rule {
    id     = "transition-ia-then-glacier"
    status = "Enabled"

    filter {
      prefix = "pgbackup/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# IAM User
resource "aws_iam_user" "barman" {
  name = "barman-backup"
  tags = {
    "CreatedBy" = "terraform"
  }
}

# IAM Policy Document
data "aws_iam_policy_document" "pgbackup-bucket" {
  statement {
    sid    = "AllowBucketList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.pgbackup-bucket.arn
    ]
  }

  statement {
    sid    = "AllowObjectOps"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.pgbackup-bucket.arn}/*"
    ]
  }
}

# IAM Policy
resource "aws_iam_policy" "barman" {
  name        = "barman-s3-access"
  description = "Allow Barman to manage backups in ${aws_s3_bucket.pgbackup-bucket.bucket}/"
  policy      = data.aws_iam_policy_document.pgbackup-bucket.json
}

resource "aws_iam_user_policy_attachment" "pgbackup-bucket-admin-attach" {
  user       = aws_iam_user.barman.name
  policy_arn = aws_iam_policy.barman.arn
}

resource "aws_iam_access_key" "barman" {
  user = aws_iam_user.barman.name
}

# Outputs
output "pgbackup-bucket" {
  value = aws_s3_bucket.pgbackup-bucket.bucket
}

output "barman-access-key-id" {
  value = aws_iam_access_key.barman.id
}

output "barman-secret-access-key" {
  value = aws_iam_access_key.barman.secret
  sensitive = true
}