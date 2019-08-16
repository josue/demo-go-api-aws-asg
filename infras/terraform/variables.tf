variable "aws_access_key_id" {
    type = "string"
    default = ""
}
variable "aws_secret_access_key" {
    type = "string"
    default = ""
}

variable "aws_region" {
    type = "string"
    default = "us-east-1"
}

variable "key_name" {
    type = "string"
    default = "api_ssh_key"
}

variable "key_priv_file" {
    type = "string"
    default = "./ssh_keys/aws_api"
}
variable "key_pub_file" {
    type = "string"
    default = "./ssh_keys/aws_api.pub"
}

variable "instance_type" {
    type = "string"
    default = "t2.micro"
}

variable "tag_release" {
    type = "string"
    default = "api-latest"
}

variable "instance_health_endpoint" {
    type = "string"
    default = "health" # ie: /health
}

variable "asg_min_instances" {
    type = "string"
    default = 1
}

variable "asg_max_instances" {
    type = "string"
    default = 5
}

variable "asg_cpu_threshold_high" {
    type = "string"
    default = 50
}

variable "asg_cpu_threshold_low" {
    type = "string"
    default = 5
}