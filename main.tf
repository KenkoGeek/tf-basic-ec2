# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "my-terraform-state-key"
#     region = var.aws_region
#     # dynamodb_table = "my-terraform-state-lock"
#   }
# }

locals {
  user_data_script = var.windows ? "${path.module}/assets/user-data.ps1" : "${path.module}/assets/user-data.sh"
}

resource "aws_ebs_encryption_by_default" "enabled" {
  count   = var.kms_key_arn == "" ? 1 : 0
  enabled = true
}

resource "aws_security_group" "ec2_instance_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the ${var.instance_name} instance"
  name        = "${var.instance_name}-sg"
  tags = merge(var.tags, {
    "Name" = "${var.instance_name}-sg"
  })

  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
      description = ingress.value.description
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

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role" "ec2_instance_role" {
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

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]
  user_data              = file(local.user_data_script)
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size           = var.ebs_volume_size
    encrypted             = true
    kms_key_id            = var.kms_key_arn == "" ? data.aws_ebs_default_kms_key.current.key_arn : var.kms_key_arn
    volume_type           = "gp3"
    delete_on_termination = true
    tags = merge(var.tags, {
      "Name" = "${var.instance_name}-ebs-root"
    })
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      encrypted             = ebs_block_device.value.encrypted
      delete_on_termination = ebs_block_device.value.delete_on_termination
      kms_key_id            = ebs_block_device.value.kms_key_id != "" ? ebs_block_device.value.kms_key_id : data.aws_ebs_default_kms_key.current.key_arn
      tags = merge(var.tags, {
        "Name" = "${var.instance_name}-ebs-${ebs_block_device.value.identifier}"
        }
      )
    }
  }

  tags = merge(var.tags, {
    "Name" = var.instance_name
  })

  private_ip = var.use_private_ip ? var.private_ip : null
}

# SNS topic for sending alerts
resource "aws_sns_topic" "ec2_alarms" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.instance_name}-alerts"
  tags = merge(var.tags, {
    "Name" = "${var.instance_name}-alerts"
  })
  kms_master_key_id = var.kms_key_arn == "" ? data.aws_kms_key.by_alias.arn  : var.kms_key_arn
}

resource "aws_sns_topic_subscription" "email_subscriptions" {
  count     = var.sns_topic_arn == "" ? length(var.email_addresses) : 0
  topic_arn = aws_sns_topic.ec2_alarms[0].arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.instance_name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.ec2_alarms[0].arn]
  tags                = var.tags

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "${var.instance_name}-high-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors ec2 memory utilization"
  alarm_actions       = [aws_sns_topic.ec2_alarms[0].arn]
  tags                = var.tags

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }
}

# resource "aws_cloudwatch_metric_alarm" "disk_root_utilization" {
#   alarm_name          = "${var.instance_name}-high-disk-root"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "disk_used_percent"
#   namespace           = "CWAgent"
#   period              = "900"
#   statistic           = "Average"
#   threshold           = "90"
#   alarm_description   = "This metric monitors ec2 root disk space utilization"
#   alarm_actions       = [aws_sns_topic.ec2_alarms[0].arn]
#   tags                = var.tags

#   dimensions = {
#     InstanceId   = aws_instance.ec2_instance.id
#     path         = "/"
#     ImageId      = var.ami
#     InstanceType = var.instance_type
#     device       = "xvda3"
#     fstype       = "xfs"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "disks_space_utilization" {
#   for_each = var.additional_volumes

#   alarm_name          = "${var.instance_name}-high-disk-${each.value.identifier}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "disk_used_percent"
#   namespace           = "CWAgent"
#   period              = "900"
#   statistic           = "Average"
#   threshold           = "90"
#   alarm_description   = "This metric monitors ec2 ${each.value.identifier} disk space utilization"
#   alarm_actions       = [aws_sns_topic.ec2_alarms[0].arn]  
#   tags                = var.tags

#   dimensions = {
#     InstanceId   = aws_instance.ec2_instance.id
#     path         = each.value.mount_point
#     ImageId      = var.ami
#     InstanceType = var.instance_type
#     device       = "xvda3"
#     fstype       = "xfs"
#   }
# }