resource "aws_iam_policy" "ec2policy" {
  name = "EC2-Profile-Policy"
  description = "IAM policy for EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:ListObject",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
            ]
            Resource = [     
                var.s3-bucket-arn,      
                "${var.s3-bucket-arn}/*"
            ]
            Effect = "Allow"
        }
    ]
  })
}

resource "aws_iam_role" "ec2role" {
  name = "EC2-Profile-Role"
  description = "IAM role for ec2role EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Effect = "Allow"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachpolicy" {
  role = aws_iam_role.ec2role.name
  policy_arn = aws_iam_policy.ec2policy.arn
}