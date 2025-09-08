resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# CloudWatch Log Group for ECS service
resource "aws_cloudwatch_log_group" "ecs_service" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.log_retention_days
  tags = {
    Name        = "${var.service_name}-logs"
    Environment = var.environment
    Service     = var.service_name
  }
}

# SSM Parameter for database password
resource "aws_ssm_parameter" "db_password" {
  count = var.db_password != "" ? 1 : 0
  
  name  = "/${var.service_name}/database/password"
  type  = "SecureString"
  value = var.db_password
  
  tags = {
    Name        = "${var.service_name}-db-password"
    Environment = var.environment
    Service     = var.service_name
  }
}

# ECS-optimized AMI data source
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch template for ECS instances
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type
  vpc_security_group_ids = var.security_groups

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
    }
  }
}

# IAM instance profile for ECS instances
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# IAM role for ECS instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.cluster_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach ECS instance policy
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# Auto Scaling Group for ECS instances
resource "aws_autoscaling_group" "ecs" {
  name                = "${var.cluster_name}-asg"
  vpc_zone_identifier = var.subnets
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "app",
      image     = var.image,
      essential = true,
      portMappings = [ 
        { 
          containerPort = var.container_port, 
          hostPort = 0, 
          protocol = "tcp" 
        } 
      ],
      environment = [
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_ENGINE"
          value = var.db_engine
        }
      ],
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = var.db_password != "" ? aws_ssm_parameter.db_password[0].arn : ""
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_service.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  # Ensure tasks are distributed across different instances
  placement_constraints {
    type       = "distinctInstance"
  }

  # Load balancer configuration for target group association
  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = "app"
      container_port   = 3000
    }
  }

  depends_on = [aws_ecs_task_definition.this, aws_autoscaling_group.ecs]
}

# Output the log group ARN for reference
output "log_group_arn" {
  description = "ARN of the CloudWatch log group for the ECS service"
  value       = aws_cloudwatch_log_group.ecs_service.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for the ECS service"
  value       = aws_cloudwatch_log_group.ecs_service.name
}
