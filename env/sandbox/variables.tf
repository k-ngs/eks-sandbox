variable "region" {
  description = "The region in which the resource will be created by default"
  type        = string
}

variable "profile" {
  description = "The aws cli profile to use for authorization"
  type        = string
}

variable "map_users" {
  type = list(string)
}

variable "env" {
  type = string
  default = "eks-sandbox"
}

locals {
  default_tags = {
    Env = var.env
  }
}