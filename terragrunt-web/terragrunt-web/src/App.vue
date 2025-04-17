<template>
  <div class="container">
    <h1>Gerador de Terragrunt</h1>

    <!-- Step de Seleção (VPC, EC2, etc) -->
    <div v-if="step === 1">
      <h2>Escolha o tipo de infraestrutura</h2>
      <button @click="selectInfrastructure('vpc')">VPC</button>
      <button @click="selectInfrastructure('ec2')">EC2</button>
    </div>

    <!-- Botão de Voltar para a Seleção de Infraestrutura -->
    <div v-if="step === 2">
      <button @click="goBack" class="back-button">Voltar</button>
    </div>

    <!-- Formulário dinâmico com base na escolha -->
    <div v-if="step === 2">
      <h2>
        Preencha os detalhes para a {{ selectedInfrastructure.toUpperCase() }}
      </h2>

      <form @submit.prevent="generateHCL">
        <!-- Campos do formulário para VPC -->
        <div v-if="selectedInfrastructure === 'vpc'">
          <input v-model="form.name" placeholder="Nome do projeto" />
          <input v-model="form.environment" placeholder="Ambiente (ex: dev)" />
          <input v-model="form.region" placeholder="Região AWS" />
          <input v-model="form.vpcCidr" placeholder="CIDR da VPC" />
          <input v-model="form.owner" placeholder="Dono do projeto" />

          <h3>Subnets</h3>
          <input
            v-model="form.publicSubnet.name"
            placeholder="Nome da subnet pública"
          />
          <input
            v-model="form.publicSubnet.cidr"
            placeholder="CIDR da subnet pública"
          />
          <input
            v-model="form.publicSubnet.az"
            placeholder="AZ da subnet pública"
          />

          <input
            v-model="form.privateSubnet.name"
            placeholder="Nome da subnet privada"
          />
          <input
            v-model="form.privateSubnet.cidr"
            placeholder="CIDR da subnet privada"
          />
          <input
            v-model="form.privateSubnet.az"
            placeholder="AZ da subnet privada"
          />
        </div>

        <!-- Campos do formulário para EC2 -->
        <div v-if="selectedInfrastructure === 'ec2'">
          <input v-model="form.name" placeholder="Nome da instância EC2" />
          <input v-model="form.environment" placeholder="Ambiente (ex: dev)" />
          <input v-model="form.region" placeholder="Região AWS" />
          <input
            v-model="form.instanceType"
            placeholder="Tipo da instância (ex: t2.micro)"
          />
          <input v-model="form.keyName" placeholder="Nome da chave SSH" />
        </div>

        <button type="submit">
          Gerar {{ selectedInfrastructure.toUpperCase() }} .hcl
        </button>
      </form>
    </div>

    <!-- Exibir o arquivo gerado -->
    <div v-if="generated">
      <h2>Preview do {{ selectedInfrastructure.toUpperCase() }}.hcl</h2>
      <pre>{{ generated }}</pre>
      <button @click="downloadHCL">Baixar arquivo</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

// Formulário de preenchimento
const form = ref({
  name: "",
  environment: "",
  region: "",
  vpcCidr: "",
  owner: "",
  instanceType: "",
  keyName: "",
  publicSubnet: {
    name: "",
    cidr: "",
    az: "",
  },
  privateSubnet: {
    name: "",
    cidr: "",
    az: "",
  },
});

const generated = ref("");
const selectedInfrastructure = ref("");
const step = ref(1); // Passo inicial

// Função para mudar o tipo de infraestrutura
function selectInfrastructure(infrastructure: string) {
  selectedInfrastructure.value = infrastructure;
  step.value = 2; // Avança para o passo do formulário
}

// Função para voltar ao menu de seleção
function goBack() {
  step.value = 1; // Volta para o passo inicial
  selectedInfrastructure.value = ""; // Limpa a escolha de infraestrutura
}

// Função para gerar o HCL
function generateHCL() {
  if (selectedInfrastructure.value === "vpc") {
    generated.value = `
terraform {
  source = "../modules/vpc"
}

inputs = {
  name        = "${form.value.name}"
  environment = "${form.value.environment}"
  region      = "${form.value.region}"

  vpc = {
    cidr_block           = "${form.value.vpcCidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Owner       = "${form.value.owner}"
      Environment = "${form.value.environment}"
    }
  }

  subnets = [
    {
      name       = "${form.value.publicSubnet.name}"
      cidr_block = "${form.value.publicSubnet.cidr}"
      az         = "${form.value.publicSubnet.az}"
    },
    {
      name       = "${form.value.privateSubnet.name}"
      cidr_block = "${form.value.privateSubnet.cidr}"
      az         = "${form.value.privateSubnet.az}"
    }
  ]
}
`.trim();
  } else if (selectedInfrastructure.value === "ec2") {
    generated.value = `
resource "aws_instance" "example" {
  ami             = "ami-12345678"
  instance_type   = "${form.value.instanceType}"
  key_name        = "${form.value.keyName}"
  region          = "${form.value.region}"
  tags = {
    Name = "${form.value.name}"
    Environment = "${form.value.environment}"
  }
}
`.trim();
  }
}

// Função para baixar o arquivo gerado
function downloadHCL() {
  const blob = new Blob([generated.value], {
    type: "text/plain;charset=utf-8",
  });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `${selectedInfrastructure.value}.hcl`;
  link.click();
}
</script>

<style scoped>
.container {
  max-width: 600px;
  margin: auto;
  padding: 2rem;
  text-align: left; /* Alinha tudo à esquerda */
}

input {
  display: block;
  margin-bottom: 10px;
  padding: 8px;
  width: 100%;
}

button {
  margin-top: 10px;
  padding: 10px 15px;
}

pre {
  background: #f0f0f0;
  padding: 1rem;
  white-space: pre-wrap;
}

.back-button {
  margin-bottom: 20px;
  padding: 10px 15px;
  background-color: #f0ad4e;
  color: white;
  border: none;
  cursor: pointer;
}

.back-button:hover {
  background-color: #ec971f;
}
</style>
