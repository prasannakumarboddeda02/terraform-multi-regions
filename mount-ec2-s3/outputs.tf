output "ec2_iam_instance_profile" {
  value = aws_iam_role.ec2role.name
}