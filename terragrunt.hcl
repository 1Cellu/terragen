terraform {
  source = "../modules/vpc"
}

inputs = {
  name        = "meu-projeto"
  environment = "dev"
  region      = "us-east-1"

  vpc = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Owner       = "devops"
      Environment = "dev"
    }
  }

  subnets = [
    {
      name       = "public-subnet-1"
      cidr_block = "10.0.1.0/24"
      az         = "us-east-1a"
    },
    {
      name       = "private-subnet-1"
      cidr_block = "10.0.2.0/24"
      az         = "us-east-1b"
    }
  ]
}
