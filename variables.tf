variable "aws_region" {
  description = "AWS region where the EC2 instance will be deployed"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^([a-z]{2}-[a-z]+-[0-9]{1})$", var.aws_region))
    error_message = "Invalid AWS region format. Please provide a valid region in the format 'us-west-2'."
  }
}

variable "windows" {
  description = "If is Windows server"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,63}$", var.vpc_id))  # Corrected regex
    error_message = "The VPC ID format is invalid. It should follow the pattern 'vpc-XXXXXXXX'."
  }
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^subnet-[a-f0-9]{8,63}$", var.subnet_id))  # Corrected regex
    error_message = "The Subnet ID format is invalid. Must follow the pattern 'subnet-XXXXXXXX'."
  }
}

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-022e1a32d3f742bd8"
  validation {
    condition     = can(regex("^ami-[a-z0-9]{17}$", var.ami))
    error_message = "The AMI ID format is invalid. It should follow the pattern 'ami-XXXXXXXX'."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Invalid EC2 instance type. Please provide a valid instance type in the format 'instanceFamily.instanceSize', for example, 't2.micro'."
  }
}

variable "key_name" {
  description = "Key Pair name"
  type        = string
  default     = "key-name"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.key_name))
    error_message = "The key pair format is invalid. Must be alphanumeric and can contain underscores (_) and hyphens (-)."
  }
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "my-ec2-instance"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance_name))
    error_message = "Invalid instance name. Please provide a valid name using lowercase letters and hyphens (-)."
  }
}

variable "use_private_ip" {
  description = "Flag to determine whether to use a private IP or public IP"
  type        = bool
  default     = true
}

variable "private_ip" {
  description = "Private IP address"
  type        = string
  default     = "10.0.0.40"
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.private_ip))
    error_message = "The format of the private IP address is invalid. It should follow the CIDR format in English (e.g., 10.0.0.20)."
  }
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.ebs_volume_size > 0 && var.ebs_volume_size <= 1000
    error_message = "Invalid EBS volume size. Please provide a volume size between 1 and 1000 GB."
  }
}

variable "kms_key_arn" {
  description = "KMS key ID to use for EBS volume encryption"
  type        = string
  default     = ""
  validation {
    condition     = var.kms_key_arn == "" || can(regex("^arn:aws:kms:.*", var.kms_key_arn))
    error_message = "Invalid KMS key ID format. Please provide a valid ARN for the KMS key."
  }
}

variable "security_group_rules" {
  description = "Map of security group rules with CIDR block, port, and description"
  type = map(object({
    cidr        = string
    port        = number
    description = string
  }))
  default = {
    ssh = {
      cidr        = "10.0.0.0/24"
      port        = 22
      description = "Allow SSH"
    }
    http = {
      cidr        = "10.0.0.0/24"
      port        = 80
      description = "Allow HTTP"
    }
    https = {
      cidr        = "10.0.0.0/24"
      port        = 443
      description = "Allow HTTPS"
    }
  }
}

variable "additional_volumes" {
  description = "Additional EBS volumes to attach to the instance. CAUTION: volumes aren't mounted automatically."
  type = map(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    identifier            = string
    mount_point           = string
    encrypted             = bool
    delete_on_termination = bool
    kms_key_id            = string
  }))
  default = {
    volume1 = {
      device_name           = "/dev/sdf"
      volume_size           = 50
      identifier            = "logs"
      mount_point           = "/mnt/logs"
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
      kms_key_id            = ""
    },
    volume2 = {
      device_name           = "/dev/sdg"
      volume_size           = 100
      identifier            = "data"
      mount_point           = "/mnt/data"
      volume_type           = "io2"
      encrypted             = true
      delete_on_termination = true
      kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-abcd-1234-abcd-1234abcd1234"
    }
  }
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send notifications to (optional). If not provided, a new topic will be created."
  type        = string
  default     = ""
  validation {
    condition     = var.sns_topic_arn == "" || can(regex("^arn:aws:sns:.*", var.sns_topic_arn))
    error_message = "Invalid SNS key ID format. Please provide a valid ARN for the SNS Topic."
  }
}

variable "email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Owner       = "Frankin Garcia"
  }
}