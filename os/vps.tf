
variable "images" {
  description = "Map host name code to OS image"
  default = {
    "fc" = "fedora-34-x64",
    "dn" = "84043396",
    "ub" = "ubuntu-21-04-x64"
  }
}

resource "digitalocean_droplet" "vps" {
  image              = var.images[substr(var.host, 0, 2)]
  name               = format("%s.%s", var.host, var.domain)
  region             = var.region
  size               = "s-1vcpu-1gb-intel"
  ipv6               = false
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
}

variable "region" {
  default = "ams3"
}

resource "digitalocean_project_resources" "vps" {
  project = data.digitalocean_project.default.id
  resources = [
    digitalocean_droplet.vps.urn
  ]
}

resource "digitalocean_record" "vps_ipv4" {
  type   = "A"
  domain = data.digitalocean_domain.default.name
  value  = digitalocean_droplet.vps.ipv4_address
  name   = var.host
  ttl    = 300
}

