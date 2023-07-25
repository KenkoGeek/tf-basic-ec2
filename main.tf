# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "my-terraform-state-key"
#     region = var.aws_region
#     # dynamodb_table = "my-terraform-state-lock"
#   }
# }

resource "aws_ebs_encryption_by_default" "enabled" {
  count   = var.kms_key_arn == "" ? 1 : 0
  enabled = true
}

resource "aws_security_group" "ec2_linux_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the ${var.instance_name}-instance"
  tags = merge(var.tags, {
    "Name" = "${var.instance_name}-sg"
  })

  dynamic "ingress" {
    for_each = split(",", var.allowed_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.security_group_cidr]
      description = "Ingress rule to allow ${var.security_group_cidr} to port ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
    description = "All outbound traffic allowed"
  }
}

resource "aws_iam_instance_profile" "ec2_linux_profile" {
  role = aws_iam_role.ec2_linux_role.name
}

resource "aws_iam_role" "ec2_linux_role" {
  name               = "${var.instance_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_eip" "public_ip" {
  count = var.use_private_ip ? 0 : 1
}

resource "aws_instance" "ec2_linux" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_linux_sg.id]
  user_data              = file("${path.module}/assets/user-data.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_linux_profile.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size           = var.ebs_volume_size
    encrypted             = true
    kms_key_id            = var.kms_key_arn == "" ? data.aws_ebs_default_kms_key.current.key_arn : var.kms_key_arn
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    "Name" = var.instance_name
  })

  private_ip = var.use_private_ip ? var.private_ip : null
}
