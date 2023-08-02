provider "aws" {

  #Specifying AWS as provider
  region = "ap-south-1"
}

resource "aws_vpc" "mern_vpc" {

  # Creating VPC
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "mern_vpc"
  }
}

resource "aws_subnet" "mern_subnet" {
  depends_on = [aws_vpc.mern_vpc, ]

  # Creating subnet
  vpc_id                  = aws_vpc.mern_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mern_subnet"
  }
}

resource "aws_internet_gateway" "mern_ig" {
  depends_on = [aws_vpc.mern_vpc, ]

  # Creating Internet Gateway
  vpc_id = aws_vpc.mern_vpc.id

  tags = {
    Name = "mern_ig"
  }
}

resource "aws_route_table" "mern_rt" {
  depends_on = [aws_vpc.mern_vpc, ]

  # Creating Routing Table
  vpc_id = aws_vpc.mern_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mern_ig.id
  }

  tags = {
    Name = "mern_rt"
  }
}

resource "aws_route_table_association" "mern_subnet_rt" {
  depends_on = [aws_route_table.mern_rt, aws_subnet.mern_subnet]

  # Associating Routing Table with Subnet
  subnet_id      = aws_subnet.mern_subnet.id
  route_table_id = aws_route_table.mern_rt.id
}

resource "aws_security_group" "mern_sg" {
  depends_on = [aws_vpc.mern_vpc, ]

  name        = "sg_allow"
  description = "https and ssh"
  vpc_id      = aws_vpc.mern_vpc.id

  # Creating Security Group
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "sg_allow"
  }
}

resource "aws_instance" "mern_os" {
  depends_on = [aws_subnet.mern_subnet, aws_security_group.mern_sg]

  # Launching EC2 instance
  ami             = "ami-0ded8326293d3201b"
  instance_type   = "t2.micro"
  key_name        =  "test-keypair"
  availability_zone = "ap-south-1a"
  security_groups = [aws_security_group.mern_sg.id, ]
  subnet_id       = aws_subnet.mern_subnet.id

  connection{
        type="ssh"
        user="ec2-user"
        private_key=file("/home/nilesh/Downloads/test-keypair.pem")
        host=aws_instance.mern_os.public_ip
  	}


  provisioner "file" {
    source      = "script.sh"
    destination = "script.sh"


  }

  provisioner "remote-exec" {
    inline = [
      "bash script.sh"
    ]
  }

  tags = {
    Name = "mern_os"
  }
}

output "mern_ip" {

  # Display the Public IP of instance on Console
  value = aws_instance.mern_os.public_ip
}
