package main

import (
	"os"
	"text/template"
)

type VPC struct {
	CIDRBlock          string
	EnableDNSSupport   bool
	EnableDNSHostnames bool
}

type Subnet struct {
	Name string
	CIDR string
	AZ   string
}

type Config struct {
	ModuleSource string
	Name         string
	Environment  string
	Region       string
	Owner        string
	VPC          VPC
	PublicSubnet Subnet
	PrivateSubnet Subnet
}

func main() {
	data := Config{
		ModuleSource: "../modules/vpc",
		Name:         "meu-projeto",
		Environment:  "dev",
		Region:       "us-east-1",
		Owner:        "devops",
		VPC: VPC{
			CIDRBlock:          "10.0.0.0/16",
			EnableDNSSupport:   true,
			EnableDNSHostnames: true,
		},
		PublicSubnet: Subnet{
			Name: "public-subnet-1",
			CIDR: "10.0.1.0/24",
			AZ:   "us-east-1a",
		},
		PrivateSubnet: Subnet{
			Name: "private-subnet-1",
			CIDR: "10.0.2.0/24",
			AZ:   "us-east-1b",
		},
	}

	tmpl, err := template.ParseFiles("terragrunt_template.hcl")
	if err != nil {
		panic(err)
	}

	outputFile, err := os.Create("terragrunt.hcl")
	if err != nil {
		panic(err)
	}
	defer outputFile.Close()

	err = tmpl.Execute(outputFile, data)
	if err != nil {
		panic(err)
	}

	println("Arquivo terragrunt.hcl gerado com sucesso!")
}
