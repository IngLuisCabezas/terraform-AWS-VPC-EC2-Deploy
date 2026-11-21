resource "aws_instance" "example" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]

  tags = {
    Name = "HelloWorld"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
