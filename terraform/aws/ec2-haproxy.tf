# networking
resource "aws_vpc" "haproxy_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "haproxy-vpc"
    }
}

resource "aws_subnet" "haproxy_subnet" {
    vpc_id = aws_vpc.haproxy_vpc.id
    cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "haproxy_internet_gateway" {
    vpc_id = aws_vpc.haproxy_vpc.id
}

resource "aws_route_table" "haproxy_route_table" {
    vpc_id = aws_vpc.haproxy_vpc.id
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.haproxy_internet_gateway.id
    }
}

resource "aws_route_table_association" "haproxy_route_table_association" {
    subnet_id = aws_subnet.haproxy_subnet.id
    route_table_id = aws_route_table.haproxy_route_table.id
}

# security groups
resource "aws_security_group" "haproxy_security_group" {
    vpc_id = aws_vpc.haproxy_vpc.id
    ingress = {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "haproxy-security-group"
    }
}

# nodes
data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-arm64-server-*"]
  }
}

variable "haproxy_count" {
    type = number
    default = 1
}

resource "aws_instance" "haproxy_node" {
  count = var.haproxy_count
    ami = data.aws_ami.ubuntu_arm64.id
    instance_type = "t4g.small"
    subnet_id = aws_subnet.haproxy_subnet.id
    vpc_security_group_ids = [aws_security_group.haproxy_security_group.id]
    
    associate_public_ip_address = false
    key_name = "haproxy-key"

    root_block_device {
      volume_size = 16
      volume_type = "gp3"
      encrypted = true
    }

    user_data = templatefile("${path.module}/user-data.yaml", {
        haproxy_config = file("${path.module}/haproxy.cfg")
    })

    tags = {
        Name = "haproxy-node-${count.index}"
    }
}

output "haproxy_nodes" {
    value = aws_instance.haproxy_node[*].public_ip
}