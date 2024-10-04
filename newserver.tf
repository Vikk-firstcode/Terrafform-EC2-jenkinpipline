terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Policy for EC2 Instances
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "A policy for EC2 instances to access EC2 metadata"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          # Add other permissions as needed
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM Policy to the Role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Variable for Server Names
variable "server_names" {
  description = "List of server names for EC2 instances"
  type        = list(string)
  default     = ["master01", "worker1", "worker2"]
}

# Create a Security Group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Security group for EC2 instances"

  ingress {
    from_port   = 22  # Allow SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this for your security needs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances with Specific Names
resource "aws_instance" "ubuntu_servers" {
  count         = length(var.server_names)
  ami           = "ami-085f9c64a9b75eed5"  # Update to the correct AMI ID for us-east-2
  instance_type = "t2.micro"
  key_name      = "VIkram_person"             # Specify your existing key pair name here

  root_block_device {
    volume_size = 15
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]  # Attach security group

  tags = {
    Name = var.server_names[count.index]  # Use specific names from the variable
  }
}

# Create inventory.ini file
resource "local_file" "inventory" {
  content = <<EOF
[ubuntu_servers]
${join("\n", [for inst in aws_instance.ubuntu_servers : "${inst.private_ip} ansible_ssh_user=ubuntu"])}
EOF

  filename = "${path.module}/inventory.ini"
}
