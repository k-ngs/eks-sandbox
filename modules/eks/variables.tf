variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "enable_irsa" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}