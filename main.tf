# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "pearl"
  # other configurations
}


# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"  # Replace with your desired availability zone
}

# Create an internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

# Create a security group
resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "example"
      image = "amazon/amazon-ecs-sample"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# Create an ECS service
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.example.id]
    security_groups = [aws_security_group.example.id]
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-05e00961530ae1b55"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example.id

  tags = {
    Name = "ExampleInstance"
  }
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.example.id
}

# Output the subnet ID
output "subnet_id" {
  value = aws_subnet.example.id
}

# Output the ECS cluster name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.example.name
}

# Output the ECS service name
output "ecs_service_name" {
  value = aws_ecs_service.example.name
}

# Output the EC2 instance public IP
output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

