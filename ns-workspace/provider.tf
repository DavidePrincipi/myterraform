terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
  }
}

variable "sshkeys" {
  description = "DigitalOcean SSH key name"
  type        = list(string)
}

provider "digitalocean" {
  token = var.do_token
  requests_per_second = var.do_requests_per_second
  http_retry_max = 5
}

variable "do_token" {
  description = "DigitalOcean API token"
}

data "digitalocean_ssh_key" "rootpkey" {
  for_each = toset(var.sshkeys)
  name     = each.value
}
