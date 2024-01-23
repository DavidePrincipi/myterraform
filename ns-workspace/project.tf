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
  type        = number
  default     = 4000
}

variable "acme_staging" {
  description = "Configure Let's Encrypt Staging environment"
  type        = bool
  default     = true
}

variable "root_password" {
  description = "Default VPS root password. If empty, a random one is generated."
  type        = string
  default     = ""
}

variable "do_requests_per_second" {
  description = "DigitalOcean API requests per second -- This can be used to enable throttling, overriding the limit of API calls per second to avoid rate limit errors, can be disabled by setting the value to 0.0"
  type        = number
  default     = 10
}

data "digitalocean_project" "default" {
  name = var.project
}

data "digitalocean_domain" "default" {
  name = var.domain
}

variable "testing_modules" {
  description = "Enable the testing versions in repository configuration"
  type        = bool
  default     = false
}
