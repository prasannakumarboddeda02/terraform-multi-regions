
variable "instance_type"{
    type = string
    default = "t3.micro"
}

variable "ami" {
  type = string
  default = "ami-00ca570c1b6d79f36"
}

variable "iam_resource_name" {
  type = string
  default = "bucket_replication-123"
}

variable "regions"{
  default = {
    region-1 = {
      region = "ap-south-1"
      ami = "ami-00ca570c1b6d79f36"
    }

    region-2 = {
      region = "ap-south-2"
      ami = "ami-0018df03456b303db"
    }
  }
}