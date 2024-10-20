resource "aws_instance" "web-server-2" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  key_name               = "chave1" #Adicione sua Key Pairs da AWS aqui!
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data              = file("script.sh")

  tags = {
    Name = "web-server-2"
  }
}


