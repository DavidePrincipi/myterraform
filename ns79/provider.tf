terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.3.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  description = "DigitalOcean API token"
}

variable "sshkeys" {
  description = "DigitalOcean SSH key name"
  type        = list(string)
}

data "digitalocean_ssh_key" "rootpkey" {
  for_each = toset(var.sshkeys)
  name     = each.value
}
