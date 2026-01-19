resource "aws_s3_bucket" "source_bucket"{
  bucket = "source-bucket-replication-123"

  force_destroy = true

  tags = {
    Name = "source bucket"
  }
}

resource "aws_s3_bucket_versioning" "source_bucket_versioning"{
  bucket = aws_s3_bucket.source_bucket.id


  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination_bucket"{
  bucket = "destination-bucket-replication-123"

  region = var.destination-bucket-region

  force_destroy = true

  tags = {
    Name = "destination bucket"
  }
}

resource "aws_s3_bucket_versioning" "destination_bucket_versioning"{
  bucket = aws_s3_bucket.destination_bucket.id

  region = var.destination-bucket-region

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for replication access
resource "aws_iam_policy" "replication_policy" {
  name = "s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention"
        ],
        Resource = "${aws_s3_bucket.source_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${aws_s3_bucket.destination_bucket.arn}/*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.source_bucket.id
  role   = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"

    filter {
      prefix = "" # replicate all objects
    }

    destination {
      bucket        = "arn:aws:s3:::${aws_s3_bucket.destination_bucket.bucket}"
      storage_class = "STANDARD"
    }
      # Add this section to handle delete marker replication
      delete_marker_replication {
      status = "Enabled"  # Can also be set to "Disabled" depending on your use case
      }
    }
  }