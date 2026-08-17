# -------------------------

# Jenkins SSH Key Pair

# -------------------------

resource "aws_key_pair" "jenkins" {
key_name   = "${var.project_name}-jenkins-key"
public_key = file(pathexpand("~/.ssh/ivolve-key.pub"))

tags = {
Name    = "${var.project_name}-jenkins-key"
Project = var.project_name
}
}

# -------------------------

# Jenkins IAM Role

# -------------------------

resource "aws_iam_role" "jenkins" {
name = "${var.project_name}-jenkins-role"

assume_role_policy = jsonencode({
Version = "2012-10-17"

Statement = [
  {
    Effect = "Allow"

    Principal = {
      Service = "ec2.amazonaws.com"
    }

    Action = "sts:AssumeRole"
  }
]

})

tags = {
Name    = "${var.project_name}-jenkins-role"
Project = var.project_name
}
}

# -------------------------

# Jenkins IAM Policy

# -------------------------

resource "aws_iam_role_policy" "jenkins" {
name = "${var.project_name}-jenkins-policy"
role = aws_iam_role.jenkins.id

policy = jsonencode({
Version = "2012-10-17"

Statement = [

  # ECR permissions for Docker push/pull
  {
    Effect = "Allow"

    Action = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    Resource = "*"
  },

  # EKS permissions required by AWS CLI / kubectl
  {
    Effect = "Allow"

    Action = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]

    Resource = "*"
  },

  # STS identity used by AWS authentication
  {
    Effect = "Allow"

    Action = [
      "sts:GetCallerIdentity"
    ]

    Resource = "*"
  }
]

})
}

# -------------------------

# Jenkins Instance Profile

# -------------------------

resource "aws_iam_instance_profile" "jenkins" {
name = "${var.project_name}-jenkins-profile"
role = aws_iam_role.jenkins.name

tags = {
Name    = "${var.project_name}-jenkins-profile"
Project = var.project_name
}
}

# -------------------------

# Jenkins Security Group

# -------------------------

resource "aws_security_group" "jenkins" {
name        = "${var.project_name}-jenkins-sg"
description = "Security group for Jenkins server"
vpc_id      = var.vpc_id

ingress {
description = "SSH"

from_port = 22
to_port   = 22
protocol  = "tcp"

cidr_blocks = [var.ssh_cidr]

}

ingress {
description = "Jenkins"

from_port = 8080
to_port   = 8080
protocol  = "tcp"

cidr_blocks = ["0.0.0.0/0"]

}

egress {
description = "Allow all outbound traffic"

from_port = 0
to_port   = 0
protocol  = "-1"

cidr_blocks = ["0.0.0.0/0"]

}

tags = {
Name    = "${var.project_name}-jenkins-sg"
Project = var.project_name
}
}

# -------------------------

# Jenkins EC2 Instance

# -------------------------

resource "aws_instance" "jenkins" {
ami           = var.ami_id
instance_type = var.instance_type

subnet_id              = var.public_subnet_id
key_name               = aws_key_pair.jenkins.key_name
vpc_security_group_ids = [aws_security_group.jenkins.id]

associate_public_ip_address = true

# Attach Jenkins IAM Role

iam_instance_profile = aws_iam_instance_profile.jenkins.name

tags = {
Name    = "${var.project_name}-jenkins"
Project = var.project_name
Role    = "Jenkins"
}
}

