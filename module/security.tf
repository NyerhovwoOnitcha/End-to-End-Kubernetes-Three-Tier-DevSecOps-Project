## security_group for eks cluster bastion
resource "aws_security_group" "eks_bastion" {
  name        = "allow_tls"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_security_group_rule" "bastion-SGR-ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_bastion.id
}
