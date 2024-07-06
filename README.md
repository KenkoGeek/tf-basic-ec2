

# Preparing the environment

1. Clone the repository using `git`
```bash
git clone the-repository/project
```
2. Change to the project directory
```bash
cd project/
```
3. Init the Terraform project
```bash
terraform init
```
4. Validate the configurations files
 ```bash
terraform validate
``` 
5. Lint the project

Installation guide for tflint -> https://github.com/terraform-linters/tflint
```bash
tflint
```
6. Validate for security best practices

Installation guide for tfsec -> https://aquasecurity.github.io/tfsec/v1.28.1/guides/installation/
```bash
tfsec
```
7. Give some format (just in case)
```bash
terraform fmt
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.50.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ebs_encryption_by_default.enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_eip.public_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.ec2_alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email_subscriptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_ebs_default_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ebs_default_kms_key) | data source |
| [aws_iam_policy_document.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.by_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_volumes"></a> [additional\_volumes](#input\_additional\_volumes) | Additional EBS volumes to attach to the instance. CAUTION: volumes aren't mounted automatically. | <pre>map(object({<br>    device_name           = string<br>    volume_size           = number<br>    volume_type           = string<br>    identifier            = string<br>    mount_point           = string<br>    encrypted             = bool<br>    delete_on_termination = bool<br>    kms_key_id            = string<br>  }))</pre> | <pre>{<br>  "volume1": {<br>    "delete_on_termination": true,<br>    "device_name": "/dev/sdf",<br>    "encrypted": true,<br>    "identifier": "logs",<br>    "kms_key_id": "",<br>    "mount_point": "/mnt/logs",<br>    "volume_size": 50,<br>    "volume_type": "gp3"<br>  },<br>  "volume2": {<br>    "delete_on_termination": true,<br>    "device_name": "/dev/sdg",<br>    "encrypted": true,<br>    "identifier": "data",<br>    "kms_key_id": "arn:aws:kms:us-east-1:123456789012:key/abcd1234-abcd-1234-abcd-1234abcd1234",<br>    "mount_point": "/mnt/data",<br>    "volume_size": 100,<br>    "volume_type": "io2"<br>  }<br>}</pre> | no |
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID | `string` | `"ami-022e1a32d3f742bd8"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the EC2 instance will be deployed | `string` | `"us-east-1"` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | Size of the EBS volume in GB | `number` | `20` | no |
| <a name="input_email_addresses"></a> [email\_addresses](#input\_email\_addresses) | List of email addresses to subscribe to the SNS topic. | `list(string)` | `[]` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the EC2 instance | `string` | `"my-ec2-instance"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key Pair name | `string` | `"key-name"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ID to use for EBS volume encryption | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address | `string` | `"10.0.0.40"` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Map of security group rules with CIDR block, port, and description | <pre>map(object({<br>    cidr        = string<br>    port        = number<br>    description = string<br>  }))</pre> | <pre>{<br>  "http": {<br>    "cidr": "10.0.0.0/24",<br>    "description": "Allow HTTP",<br>    "port": 80<br>  },<br>  "https": {<br>    "cidr": "10.0.0.0/24",<br>    "description": "Allow HTTPS",<br>    "port": 443<br>  },<br>  "ssh": {<br>    "cidr": "10.0.0.0/24",<br>    "description": "Allow SSH",<br>    "port": 22<br>  }<br>}</pre> | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic to send notifications to (optional). If not provided, a new topic will be created. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | <pre>{<br>  "Environment": "Development",<br>  "Owner": "Frankin Garcia"<br>}</pre> | no |
| <a name="input_use_private_ip"></a> [use\_private\_ip](#input\_use\_private\_ip) | Flag to determine whether to use a private IP or public IP | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |
| <a name="input_windows"></a> [windows](#input\_windows) | If is Windows server | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the EC2 instance |
| <a name="output_instance_ip"></a> [instance\_ip](#output\_instance\_ip) | IP address of the EC2 instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |

