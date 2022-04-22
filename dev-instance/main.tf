terraform {
  backend "s3" {
    bucket = "account-tf-state-bucket-9"
    key    = "dev-instance.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
}

# Get latest Red Hat Enterprise Linux 8.x AMI
data "aws_ami" "rhel8" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-8.*HVM-2022*arm64*"]
  }
}

resource "random_id" "instance_id" {
  byte_length = 2
}

resource "aws_instance" "dev1" {
  ami                  = data.aws_ami.rhel8.id # latest rhel 8
  instance_type        = "t4g.small"           # bursrtable graviton instance with 2 cpu and 2GiB of ram
  ebs_optimized        = true
  iam_instance_profile = "EC2-SSM" # Manage instance with Systems Manager
  root_block_device {
    delete_on_termination = true
    volume_size = 30
    volume_type = "gp3"
  }
  subnet_id              = var.my_subnet_id
  vpc_security_group_ids = [var.my_sg]
  key_name               = var.my_key
  user_data = <<EOF
#!/bin/bash
dnf install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_arm64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent
dnf upgrade -y
dnf install -y python39 git jq vim 
python3 -m pip install --upgrade pip
python3 -m pip install pylint
python3 -m pip install black
python3 -m pip install checkov
dnf remove -y container-tools
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce
usermod -aG docker ec2-user
systemctl enable --now docker
dc_ver=$(curl -sL https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name")
echo $dc_ver
mkdir -p /usr/local/lib/docker/cli-plugins
curl -L https://github.com/docker/compose/releases/download/$dc_ver/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose
reboot
EOF
  tags = {
    Name    = "t4g-dev-${random_id.instance_id.dec}"
    Org     = "myorg"
    Team    = "my-admins"
    project = "dev-tools"
  }
}
