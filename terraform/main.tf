# Generate private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair using the generated public key
resource "aws_key_pair" "serpent_key" {
  key_name   = "serpent-surge-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save private key to file
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "../.keys/serpent-surge.pem"
  file_permission = "0400"
}


resource "aws_instance" "serpent_surge" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.game_subnet.id
  vpc_security_group_ids = [aws_security_group.game_server_sg.id]
  key_name               = aws_key_pair.serpent_key.key_name

  tags = {
    Name        = "serpent-surge-server-${count.index + 1}"
    Project     = "serpent-surge"
    Environment = "development"
    Description = "Web server for my application"
  }
}

resource "null_resource" "ansible_provisioner" {
  depends_on = [aws_instance.serpent_surge, local_file.env_file]

  triggers = {
    instance_ids = join(",", aws_instance.serpent_surge[*].id)
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 30 && \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ANSIBLE_STDOUT_CALLBACK=yaml \
      ansible-playbook \
        -i inventory.aws_ec2.yml \
        ansible/main.yml
    EOT
    working_dir = "../"
  }
}


