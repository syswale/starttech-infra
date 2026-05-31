# 1. IAM Role with secure SSM & KMS fetching
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    effect = "Allow"
    actions = ["ssm:GetParameter", "kms:Decrypt"]
    resources = [
      "arn:aws:ssm:${var.aws_region}:*:parameter/starttech/prod/mongodb_uri",
      "arn:aws:kms:${var.aws_region}:*:key/*"
    ]
  }
}

resource "aws_iam_role_policy" "ssm_policy" {
  name   = "${var.project_name}-ssm-policy"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.ssm_access.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# 2. Application Load Balancer & Target Group
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# 3. Launch Template & Auto Scaling Group
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  iam_instance_profile { arn = aws_iam_instance_profile.ec2.arn }
  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region      = var.aws_region
    ecr_image_uri   = var.ecr_image_uri
    jwt_secret      = var.jwt_secret
    redis_endpoint  = var.redis_endpoint
    log_group_name  = var.log_group_name
  }))
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.backend.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}