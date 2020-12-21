terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "1.22.2"
    }
  }
}

variable "sshkey" {
  description = "DigitalOcean SSH key name"
}

data "digitalocean_ssh_key" "terraform" {
  name = var.sshkey
}
