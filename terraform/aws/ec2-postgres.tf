# security groups
resource "aws_security_group" "postgres_security_group" {
    vpc_id = aws_vpc.haproxy_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production
  }

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["100.64.0.0/10"] # Allow Tailscale range
  }

  ingress {
    description = "Patroni REST"
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["100.64.0.0/10"]
  }

  ingress {
    description = "etcd peer + client"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["100.64.0.0/10"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "postgres-sg" }

}

# nodes
data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

variable "postgres_count" {
    type = number
    default = 3
}

resource "aws_instance" "postgres_node" {
    count = var.postgres_count
    ami = data.aws_ami.ubuntu_arm64.id
    instance_type = "t4g.medium"
    subnet_id = aws_subnet.postgres_subnet.id
    vpc_security_group_ids = [aws_security_group.postgres_security_group.id]
    associate_public_ip_address = false
    key_name = "postgres-key"

    root_block_device {
      volume_size = 30
      volume_type = "gp3"
      encrypted = true
    }

    tags = {
        Name = "postgres-node-${count.index}"
    }
}

output "postgres_nodes" {
    value = aws_instance.postgres_node[*].public_ip
}