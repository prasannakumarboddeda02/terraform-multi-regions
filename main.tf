terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
      }
    }

    backend "s3" {
      bucket = "state-storage-bucket-001"
      key = "terraform.tfstate"
      region = "ap-south-1"
    }
}

/*resource "aws_s3_bucket" "state_bucket" {
    bucket = "state-storage-bucket-001"
    lifecycle {
    prevent_destroy = true
  }
}*/

provider "aws"{
    region = "ap-south-1"
}

provider "aws" {
    region = "ap-south-2"
    alias = "region2"
}


module "ec2"{
    source = "./ec2"

    regions = var.regions

    type = var.instance_type

    EC2-IAM-profile = module.mount-IAM-policy.ec2_iam_instance_profile

}


module "s3-bucket-replication"{
  source = "./bucket-replication"

  destination-bucket-region = var.regions.region-2.region
}

resource "aws_s3_bucket" "mount_bucket" {
  bucket = "storage-bucket-ec2-123"

  force_destroy = true

  tags = {
    Name = "Mount-bucket-ec2"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketowner" {
  bucket = aws_s3_bucket.mount_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


module "mount-IAM-policy"{
  source = "./mount-ec2-s3"

  s3-bucket-arn = aws_s3_bucket.mount_bucket.arn
}