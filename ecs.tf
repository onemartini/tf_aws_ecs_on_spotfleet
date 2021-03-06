resource "aws_iam_policy_attachment" "ecs_service" {
  name       = "${var.app_name}-ecs-service"
  roles      = ["${aws_iam_role.ecs_service.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role" "ecs_service" {
  name = "${var.app_name}-ec2-service"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ecs.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}"
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.task_name}"

  container_definitions = "${file(var.container_definitions_file)}"
}

resource "aws_ecs_service" "main" {
  name            = "${var.app_name}"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.main.arn}"
  desired_count   = "${var.service_count}"
  iam_role        = "${aws_iam_role.ecs_service.arn}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.main.id}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }

  depends_on = ["aws_alb_target_group.main", "aws_alb.main", "aws_alb_listener.https"]
}
