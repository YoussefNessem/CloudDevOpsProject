data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name

  vpc_cidr = "10.0.0.0/16"

  availability_zones = [
    "eu-north-1a",
    "eu-north-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

module "server" {
  source = "./modules/server"

  project_name = var.project_name

  vpc_id = module.network.vpc_id

  public_subnet_id = module.network.public_subnet_ids[0]

  ami_id = data.aws_ssm_parameter.amazon_linux_2023_ami.value

  instance_type = "t3.small"

  ssh_cidr = "0.0.0.0/0"
}

module "ecr" {
  source = "./modules/ecr"

  project_name    = var.project_name
  repository_name = "ivolve-app"
}

module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  jenkins_security_group_id = module.server.jenkins_security_group_id
  jenkins_role_arn          = module.server.jenkins_role_arn

  cluster_version    = "1.33"
  node_instance_type = "t3.small"
  node_desired_size  = 2
  node_min_size      = 2
  node_max_size      = 2
}
