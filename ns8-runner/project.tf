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
}

variable "github_repo" {
  type = string
  default = "NethServer/ns8-scratchpad"
}

variable "github_user" {
  type = string
}

variable "github_token" {
  type = string
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}

