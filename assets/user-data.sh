#!/bin/bash

. /etc/os-release

# Determine architecture
architecture=$(uname -m)
if [[ "$architecture" == "x86_64" ]]; then
    arch_string="amd64"
elif [[ "$architecture" == "aarch64" ]]; then
    arch_string="arm64"
else
    echo "Unsupported architecture: $architecture"
    exit 1
fi

echo "Installing the cloudwatch and ssm agent for $NAME..."

case $NAME in
    "Amazon Linux") 
        sudo yum install -y amazon-cloudwatch-agent
        ;;
    "CentOS Stream") 
        curl -o amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/centos/$arch_string/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
        curl -o amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$arch_string/amazon-ssm-agent.rpm
        sudo rpm -U ./amazon-ssm-agent.rpm
        ;;
    "Oracle Linux Server") 
        curl -o amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/oracle_linux/$arch_string/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
        curl -o amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$arch_string/amazon-ssm-agent.rpm
        sudo rpm -U ./amazon-ssm-agent.rpm
        ;;
    "Debian GNU/Linux") 
        curl -o amazon-cloudwatch-agent.deb https://s3.amazonaws.com/amazoncloudwatch-agent/debian/$arch_string/latest/amazon-cloudwatch-agent.deb
        sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
        curl -o amazon-ssm-agent.deb https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_$arch_string/amazon-ssm-agent.deb
        sudo dpkg -i -E ./amazon-ssm-agent.deb
        ;;
    "Red Hat Enterprise Linux") 
        curl -o amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/$arch_string/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
        curl -o amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$arch_string/amazon-ssm-agent.rpm
        sudo rpm -U ./amazon-ssm-agent.rpm
        ;;
    "Rocky Linux") 
        curl -o amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/$arch_string/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
        dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$arch_string/amazon-ssm-agent.rpm
        ;;
    "SLES") 
        curl -o amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/$arch_string/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
        sudo zypper install -y amazon-ssm-agent
        ;;
    "Ubuntu") 
        curl -o amazon-cloudwatch-agent.deb https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/$arch_string/latest/amazon-cloudwatch-agent.deb
        sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
        ;;
    *)
        echo "Operating system not supported. Please refer to the official documents for more info https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-first-instance.html"
esac

json_content='{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "aggregation_dimensions": [
            [
                "InstanceId"
            ]
        ],
        "append_dimensions": {
            "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
            "ImageId": "${aws:ImageId}",
            "InstanceId": "${aws:InstanceId}",
            "InstanceType": "${aws:InstanceType}"
        },
        "metrics_collected": {
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "statsd": {
                "metrics_aggregation_interval": 60,
                "metrics_collection_interval": 60,
                "service_address": ":8125"
            }
        }
    }
}'

echo "$json_content" > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable and Start
sudo systemctl enable amazon-cloudwatch-agent amazon-ssm-agent
sudo systemctl start amazon-cloudwatch-agent amazon-ssm-agent
