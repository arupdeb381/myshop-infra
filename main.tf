resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myshop-infra"
  }
}

resource "aws_subnet" "main-public-subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "myshop-infra-public-subnet"
  }
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "myshop-infra-igw"
  }
}

resource "aws_route_table" "main-rt" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "myshop-infra-rt"
  }
}
resource "aws_route_table_association" "main-rt-association" {
  subnet_id      = aws_subnet.main-public-subnet.id
  route_table_id = aws_route_table.main-rt.id
}
resource "aws_route" "main-route" {
  route_table_id         = aws_route_table.main-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
  depends_on = [aws_internet_gateway.main-igw]

}

resource "aws_security_group" "main-sg" {
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
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
    Name = "myshop-infra-sg"
  }
}

resource "aws_key_pair" "main-key" {
  key_name   = "myshop-infra-key"
  public_key = file("terra-key-ec2.pub") # Replace with your actual public key
}

resource "aws_instance" "main-instance" {
  ami           = "ami-081b0a6eac00b4f53" # Ubuntu
  instance_type = "c7i-flex.large"
  subnet_id     = aws_subnet.main-public-subnet.id
  security_groups = [aws_security_group.main-sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.main-key.key_name
  user_data = file("userdata-node01.sh")
  availability_zone = "us-east-1a" # Replace with your desired availability zone
    root_block_device {
    volume_type = "gp3"
    volume_size = 25
  }

  tags = {
    Name = "myshop-infra"
  }
}


output "primary_serverip" {
  value = aws_instance.main-instance.public_ip
}

