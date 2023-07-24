

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.3.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_eip.public_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.ec2_linux_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_linux_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.ec2_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_linux_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ebs_default_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ebs_default_kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | List of allowed ports separated by commas | `string` | `"22,80,443"` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID | `string` | `"ami-022e1a32d3f742bd8"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the EC2 instance will be deployed | `string` | `"us-east-1"` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | Size of the EBS volume in GB | `number` | `20` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the EC2 instance | `string` | `"my-ec2-instance"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key Pair name | `string` | `"key-name"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ID to use for EBS volume encryption | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address | `string` | `"10.0.0.40"` | no |
| <a name="input_security_group_cidr"></a> [security\_group\_cidr](#input\_security\_group\_cidr) | CIDR block for the security group | `string` | `"10.0.0.0/24"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | <pre>{<br>  "Environment": "Development",<br>  "Owner": "Frankin Garcia"<br>}</pre> | no |
| <a name="input_use_private_ip"></a> [use\_private\_ip](#input\_use\_private\_ip) | Flag to determine whether to use a private IP or public IP | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the EC2 instance |
| <a name="output_instance_ip"></a> [instance\_ip](#output\_instance\_ip) | IP address of the EC2 instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |


