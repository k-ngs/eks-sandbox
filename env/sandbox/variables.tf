variable "region" {
  description = "The region in which the resource will be created by default"
  type        = string
}

variable "profile" {
  description = "The aws cli profile to use for authorization"
  type        = string
}

variable "env" {
  type = string
  default = "eks-sandbox"
}

variable "cluster_name" {
  type = string
  default = "eks-sandbox-cluster"
}

locals {
  default_tags = {
    Env = var.env
  }
}