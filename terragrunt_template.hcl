terraform {
  source = "{{ .ModuleSource }}"
}

inputs = {
  name        = "{{ .Name }}"
  environment = "{{ .Environment }}"
  region      = "{{ .Region }}"

  vpc = {
    cidr_block           = "{{ .VPC.CIDRBlock }}"
    enable_dns_support   = {{ .VPC.EnableDNSSupport }}
    enable_dns_hostnames = {{ .VPC.EnableDNSHostnames }}
    tags = {
      Owner       = "{{ .Owner }}"
      Environment = "{{ .Environment }}"
    }
  }

  subnets = [
    {
      name       = "{{ .PublicSubnet.Name }}"
      cidr_block = "{{ .PublicSubnet.CIDR }}"
      az         = "{{ .PublicSubnet.AZ }}"
    },
    {
      name       = "{{ .PrivateSubnet.Name }}"
      cidr_block = "{{ .PrivateSubnet.CIDR }}"
      az         = "{{ .PrivateSubnet.AZ }}"
    }
  ]
}
