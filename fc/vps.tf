
data "digitalocean_image" "fc" {
  slug = "fedora-33-x64"
}

resource "digitalocean_droplet" "vps" {
  image              = data.digitalocean_image.fc.id
  name               = var.host
  region             = var.region
  size               = "s-1vcpu-1gb"
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

