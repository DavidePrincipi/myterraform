variable "project" {
  description = "Project name"
}

variable "domain" {
  description = "Personal DNS domain suffix"
  default     = "nethserver.net"
}

variable "nodes" {
  description = "Host name for the VPS"
  type        = map(string)
  default     = {}
}

variable "install_branch" {
  description = "Name of code branch / image tag to install"
  type        = string
  default     = ""
}

variable "install_modules" {
  description = "Name of modules to pull from the install_branch"
  type        = string
  default     = ""
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}

