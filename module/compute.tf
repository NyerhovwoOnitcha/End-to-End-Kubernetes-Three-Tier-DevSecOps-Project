data "aws_iam_instance_profile" "admin_profile" {
  name = "eks_project"
}


resource "aws_instance" "eksclusterBastion" {
  ami                         = ami-075449515af5df0d1
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.public-subnet[0].id
  vpc_security_group_ids      = aws_security_group.eks_bastion.id
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile = data.aws_iam_instance_profile.admin_profile.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  user_data = <<-EOF
              # Installing AWS CLI
              #!/bin/bash
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              sudo apt install unzip -y
              unzip awscliv2.zip
              sudo ./aws/install

              # Installing Kubectl
              #!/bin/bash
              sudo apt update
              sudo apt install curl -y
              sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
              sudo chmod +x kubectl
              sudo mv kubectl /usr/local/bin/
              kubectl version --client

              # Installing eksctl
              #! /bin/bash
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
              sudo mv /tmp/eksctl /usr/local/bin
              eksctl version

              # Installing Helm
              #! /bin/bash
              sudo snap install helm --classic
              EOF


 tags =(
     Name = "eksclusterBastion"
  )
}




