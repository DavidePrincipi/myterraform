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

variable "install_url" {
  description = "Download URL of install.sh"
  type        = string
  default     = "https://raw.githubusercontent.com/NethServer/ns8-core/main/core/install.sh"
}

variable "install_args" {
  description = "Arguments to the install script"
  type        = string
  default     = "ghcr.io/nethserver/core:latest"
}

variable "swapsz" {
  description = "Create a memory swapfile of the given size (MB)"
  type = number
  default = 0
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}

