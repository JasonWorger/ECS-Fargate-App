data "aws_vpc" "existing" {
  id = var.vpc_id  
}
#Using a VPC which is already created within the AWS account, therfore no need to create a new one. 

resource "aws_security_group" "alb_sg" {
  vpc_id = data.aws_vpc.existing.id
  name   = "alb-security-group"
  # Inbound and outbound rules
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

resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.existing.id
  name   = "ecs-security-group"
  # Inbound and outbound rules
  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
    description      = "Only allows all inbound traffic from the alb security group on port 5000"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Task defntion which defines the container specifications.
resource "aws_ecs_task_definition" "task_definition" {
  family                = var.cluster_service_task_name
  network_mode          = "awsvpc"
  memory                = "512"
  requires_compatibilities = ["FARGATE"]


  execution_role_arn    = var.execution_role_arn  #Using existing role that already exists within the AWS account


  container_definitions = jsonencode([
    {
      name      = "flask-api-container"
      image     = var.image_id  
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol       = "tcp"
        }
      ]
    }
  ])

  cpu = "256"  
}

#creates a cluster which then groups any tasks or services within it
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

#esc service which deploys and manages the container instances
resource "aws_ecs_service" "service" {
  name            = var.cluster_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_target_group.arn
    container_name   = "flask-api-container"
    container_port   = 5000
  }

  network_configuration {
    subnets          = [var.vpc_id_subnet_list[0], var.vpc_id_subnet_list[1]]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.flask_app_listener]

}

resource "aws_lb" "flask_alb" {
  name               = "flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets          = [var.vpc_id_subnet_list[0], var.vpc_id_subnet_list[1]]

  enable_deletion_protection = false
  idle_timeout               = 400
  drop_invalid_header_fields = true

  tags = {
    Name = "flask-alb"
  }
}

resource "aws_lb_listener" "flask_app_listener" {
  load_balancer_arn = aws_lb.flask_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.flask_target_group.arn
  }
}


resource "aws_lb_target_group" "flask_target_group" {
  name     = "flask-target-group"
  port     = 5000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "5000"
    interval            = 180
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"  # Expected HTTP code for a healthy response
  }

  tags = {
    Name = "flask-target-group"
  }
}
