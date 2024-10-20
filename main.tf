variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

# Configuração do provider AWS
provider "aws" {                        
  region     = "us-east-1"              
  access_key = var.aws_access_key  
  secret_key = var.aws_secret_key      
}

# Importar a VPC existente
data "aws_vpc" "existing" {
   id = var.vpc_id  # Usando a variável para o ID da VPC
   }

# Importar o Internet Gateway existente 
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Atualizar a tabela de rotas da VPC
resource "aws_route_table" "my_route_table" {
  vpc_id = data.aws_vpc.existing.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing.id  # Usando o IGW existente
  }

  tags = {
    Name = "MyRouteTable"
  }
}

# Associar a tabela de rotas à subnet (substitua pelo ID da sua subnet)
resource "aws_route_table_association" "my_route_association" {
  subnet_id      = "subnet-090cf33876fdfc8cc"  # Substitua pelo ID da sua subnet
  route_table_id = aws_route_table.my_route_table.id
}

# Criar Grupo de Segurança 
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "web_server_sg"
  vpc_id      = data.aws_vpc.existing.id
}

# Criar regras de segurança
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_traffic" {
  type              = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
