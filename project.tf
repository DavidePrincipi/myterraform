variable "project" {
  description = "Project name"
}

variable "domain" {
  description = "Personal DNS domain suffix"
  default     = "nethserver.net"
}

data "digitalocean_image" "image_nscom" {
  name = "nethserver-7.9.2009"
}

data "digitalocean_image" "image_nsent" {
  name = "nethserver-enterprise-7.9.2009"
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}