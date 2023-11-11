# Define AWS provider
provider "aws" {
  region = "DemoDiff_aws_region"
}

# Create IAM roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "api_gateway_execution_role" {
  name = "api_gateway_execution_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach policies to IAM roles
resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayInvokeFullAccess"
  role       = aws_iam_role.api_gateway_execution_role.name
}

# Create VPC
resource "aws_vpc" "demodiff" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "demodiff-vpc"
  }
}

# Create subnets in two availability zones
resource "aws_subnet" "subnet_az1" {
  vpc_id                  = aws_vpc.demodiff.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "DemoDiff_az1"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-az1"
  }
}

resource "aws_subnet" "subnet_az2" {
  vpc_id                  = aws_vpc.demodiff.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "DemoDiff_az2"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-az2"
  }
}

# Create security group
resource "aws_security_group" "demodiff" {
  name        = "demodiff-sg"
  description = "demodiff security group for ECS"
  vpc_id      = aws_vpc.demodiff.id

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create ECS cluster
resource "aws_ecs_cluster" "demodiff" {
  name = "demodiff-cluster"
}

# Create ECR repository
resource "aws_ecr_repository" "demodiff" {
  name = "demodiff-repo"
}

# Define ECS task definition
data "aws_ecs_task_definition" "demodiff" {
  task_definition = aws_ecs_task_definition.demodiff.family
}

resource "aws_ecs_task_definition" "demodiff" {
  family                   = "demodiff-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<DEFINITION
  [
    {
      "name": "demodiff-container",
      "image": "${aws_ecr_repository.demodiff.repository_url}:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION
}

# Create ECS service
resource "aws_ecs_service" "demodiff" {
  name            = "demodiff-service"
  cluster         = aws_ecs_cluster.demodiff.id
  task_definition = aws_ecs_task_definition.demodiff.arn
  launch_type     = "EC2"
  desired_count   = 2
  subnet_ids      = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  security_groups = [aws_security_group.demodiff.id]
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "demodiff" {
  name        = "demodiff-api"
  description = "demodiff API"
}

resource "aws_api_gateway_resource" "demodiff" {
  rest_api_id = aws_api_gateway_rest_api.demodiff.id
  parent_id   = aws_api_gateway_rest_api.demodiff.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "diff" {
  rest_api_id = aws_api_gateway_rest_api.demodiff.id
  parent_id   = aws_api_gateway_resource.demodiff.id
  path_part   = "diff"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id = aws_api_gateway_rest_api.demodiff.id
  resource_id = aws_api_gateway_resource.diff.id
  http_method = "POST"
}

resource "aws_api_gateway_integration" "demodiff" {
  rest_api_id             = aws_api_gateway_rest_api.demodiff.id
  resource_id             = aws_api_gateway_resource.diff.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_ecs_service.demodiff.task_definition.apply(task_definition => "${aws_ecs_cluster.demodiff.name}/${task_definition}")
}

resource "aws_api_gateway_deployment" "demodiff" {
  depends_on = [
    aws_api_gateway_integration.demodiff,
  ]
  rest_api_id = aws_api_gateway_rest_api.demodiff.id
  stage_name  = "prod"
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.demodiff.invoke_url
}

# Create API Gateway IAM Role
resource "aws_iam_role" "api_gateway_lambda_role" {
  name = "api_gateway_lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach policies to API Gateway IAM Role
resource "aws_iam_role_policy_attachment" "api_gateway_lambda_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.api_gateway_lambda_role.name
}

# Lambda function IAM Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach policies to Lambda function IAM Role
resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Create ALB
resource "aws_lb" "demodiff" {
  name               = "demodiff-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demodiff.id]
  subnets            = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  enable_deletion_protection = false
}

# Create ALB Listener
resource "aws_lb_listener" "demodiff" {
  load_balancer_arn = aws_lb.demodiff.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

# Create ALB Target Group
resource "aws_lb_target_group" "demodiff" {
  name     = "demodiff-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demodiff.id

  health_check {
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }
}

# Attach ECS service to ALB Target Group
resource "aws_ecs_service" "demodiff" {
  # ... (Existing ECS service configurations)

  load_balancer {
    target_group_arn = aws_lb_target_group.demodiff.arn
    container_name   = "demodiff-container"
    container_port   = 80
  }
}