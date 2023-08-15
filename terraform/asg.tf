resource "aws_launch_template" "asg_template" {
  name_prefix   = "poc_charla"
  image_id      = "ami-03d5206772384973c"
  instance_type = "t2.micro"
  key_name      = "devco-czuluaga"
  # security_group_names = [aws_security_group.sg_asg.name]
  vpc_security_group_ids = [aws_security_group.sg_asg.id]
}

resource "aws_autoscaling_group" "asg_group" {
  # availability_zones  = ["us-east-1a", "us-east-1b"]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg_group.id
  lb_target_group_arn    = aws_lb_target_group.tg_charla.arn
}

resource "aws_lb" "balancer" {
  name               = "poc-charla-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_asg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_charla.arn
  }
}

resource "aws_lb_target_group" "tg_charla" {
  name        = "tg-front"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

