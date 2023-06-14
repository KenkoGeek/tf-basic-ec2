#!/bin/bash
if [[ "$(uname -s)" == "Linux" ]]; then
  # Install CloudWatch Agent for Linux
  if [[ -f /etc/redhat-release ]]; then
    # RHEL, CentOS, Amazon Linux
    sudo yum install -y amazon-cloudwatch-agent
  elif [[ -f /etc/debian_version ]]; then
    # Debian
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    sudo apt-get -y install -f
  else
    echo "Unsupported Linux distribution"
    exit 1
  fi
  
  # Install SSM Agent (only for Debian)
  if [[ -f /etc/debian_version ]]; then
    # Debian
    wget https://s3.amazonaws.com/amazon-ssm-${var.aws_region}/latest/debian_amd64/amazon-ssm-agent.deb
    sudo dpkg -i amazon-ssm-agent.deb
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  fi
fi
