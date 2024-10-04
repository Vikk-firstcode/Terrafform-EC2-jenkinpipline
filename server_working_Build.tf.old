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
  description = "A policy for EC2 instances to access S3 and other services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
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
  default     = ["srvik1", "srvik2", "srvik3"]
}

# EC2 Instances with Specific Names
resource "aws_instance" "ubuntu_servers" {
  count         = length(var.server_names)
  ami           = "ami-0c55b159cbfafe1f0"  # Update to the correct AMI ID for us-east-1
  instance_type = "t2.micro"
  key_name      = "vikram-jk"             # Specify your existing key pair name here

  root_block_device {
    volume_size = 15
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

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
