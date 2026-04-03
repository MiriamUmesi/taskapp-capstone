# IAM user specifically for Kops to create and manage the cluster
resource "aws_iam_user" "kops" {
  name = "${var.project_name}-kops"

  tags = {
    Purpose = "Kops cluster management"
  }
}

# Access key for the Kops user
resource "aws_iam_access_key" "kops" {
  user = aws_iam_user.kops.name
}

# Kops needs these 5 permissions to build and manage a cluster
resource "aws_iam_user_policy_attachment" "kops_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  ])

  user       = aws_iam_user.kops.name
  policy_arn = each.value
}
