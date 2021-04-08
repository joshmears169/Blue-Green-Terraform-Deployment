variable "region" {
  default = "eu-west-2"
}

variable "project_name" {
  type = string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnets_cidr_public" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnets_cidr_private" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "webservers_ami" {
  default = "ami-0ffd774e02309201f"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "database_name" {}

variable "database_user" {}

variable "database_password" {}

variable "enable_blue_env" {
  description = "Enable blue environment"
  type        = bool
  default     = true
}

variable "blue_instance_count" {
  description = "Number of instances in blue environment"
  type        = number
  default     = 2
}

variable "enable_green_env" {
  description = "Enable green environment"
  type        = bool
  default     = true
}

variable "green_instance_count" {
  description = "Number of instances in green environment"
  type        = number
  default     = 2
}

variable "traffic_distribution" {
  description = "Levels of traffic distribution"
  type        = string
}