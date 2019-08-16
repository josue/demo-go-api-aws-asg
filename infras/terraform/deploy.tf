provider "aws" {
    access_key = "${var.aws_access_key_id}"
    secret_key = "${var.aws_secret_access_key}"
    region     = "${var.aws_region}"
}

data "aws_availability_zones" "all" {}

data "aws_ami" "api_server" {
    most_recent = true
    owners = ["self"]

    filter {
        name   = "tag:Release"
        values = ["${var.tag_release}"]
    } 

    tags = {
        Name = "api_server"
    }
}

# resource "aws_key_pair" "api_key" {
#     key_name   = "${var.key_name}"
#     public_key = "${file(var.key_pub_file)}"
# }

resource "aws_security_group" "api_websg" {
    name = "api_websg"
    description = "Allow inbound 80/433, Allow all outbound traffic"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "api_websg"
    }
}

resource "aws_elb" "api_elb" {
    name = "api-elb"
    availability_zones = "${data.aws_availability_zones.all.names}"
    security_groups = ["${aws_security_group.api_websg.id}"]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        target = "HTTP:80/${var.instance_health_endpoint}"
        healthy_threshold = 2
        unhealthy_threshold = 5
        timeout = 3
        interval = 30
    }

    tags = {
        Name = "api_elb"
    }
}

resource "aws_launch_configuration" "api_lc" {
    name            = "api_lc"
    #key_name        = "${aws_key_pair.api_key.key_name}"
    image_id        = "${data.aws_ami.api_server.id}"
    instance_type   = "${var.instance_type}"
    security_groups = ["${aws_security_group.api_websg.id}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "api_asg" {
    name                 = "api_asg"
    launch_configuration = "${aws_launch_configuration.api_lc.name}"
    availability_zones   = "${data.aws_availability_zones.all.names}"
    load_balancers       = ["${aws_elb.api_elb.id}"]

    min_size                  = "${var.asg_min_instances}"
    max_size                  = "${var.asg_max_instances}"
    health_check_grace_period = 30
    health_check_type         = "EC2"
    force_delete              = true

    lifecycle {
        create_before_destroy = true
    }

    tag {
        key = "Name"
        value = "API Workers"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "api_workers_scale_up" {
    name = "api_workers_scale_up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 150
    autoscaling_group_name = "${aws_autoscaling_group.api_asg.name}"
}

resource "aws_autoscaling_policy" "api_workers_scale_down" {
    name = "api_workers_scale_down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.api_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "api_workers_cpu_high" {
    alarm_name = "api_workers_cpu_high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "${var.asg_cpu_threshold_high}"

    alarm_description = "Monitors EC2 high CPU utilization on API workers"
    alarm_actions = [
        "${aws_autoscaling_policy.api_workers_scale_up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.api_asg.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "api_workers_cpu_low" {
    alarm_name = "api_workers_cpu_low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "${var.asg_cpu_threshold_low}"

    alarm_description = "Monitors EC2 low CPU utilization on API workers"
    alarm_actions = [
        "${aws_autoscaling_policy.api_workers_scale_down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.api_asg.name}"
    }
}