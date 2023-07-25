data "aws_ebs_default_kms_key" "current" {}

data "aws_iam_policy_document" "ec2_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

