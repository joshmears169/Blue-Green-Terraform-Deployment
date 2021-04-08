variable "web_lb_security_group" {}

variable "public_subnet_ids" {}

variable "blue_target_group" {}

variable "green_target_group" {}

locals {
  traffic_dist_map = {
    full-blue = {
      blue  = 100
      green = 0
    }
    blue-90 = {
      blue  = 90
      green = 10
    }
    even-split = {
      blue  = 50
      green = 50
    }
    green-90 = {
      blue  = 10
      green = 90
    }
    full-green = {
      blue  = 0
      green = 100
    }
  }
}

variable "traffic_distribution" {}

variable "project_name" {}