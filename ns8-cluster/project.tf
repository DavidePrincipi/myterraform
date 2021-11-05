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

variable "wgnet" {
  description = "WireGuard VPN network"
  default     = "10.5.4.0/24"
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}

