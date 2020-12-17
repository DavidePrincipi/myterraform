resource "digitalocean_droplet" "vps" {
  image              = digitalocean_custom_image.fcos.id
  name               = var.host
  region             = var.region
  size               = "s-1vcpu-1gb"
  ipv6               = false
  private_networking = true
  user_data          = file("${path.module}/vps.ign")
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
}

variable "region" {
  default = "ams3"
}

resource "digitalocean_custom_image" "fcos" {
  name    = "FCOS33"
  url     = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/33.20201201.3.0/x86_64/fedora-coreos-33.20201201.3.0-digitalocean.x86_64.qcow2.gz"
  regions = [var.region]
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

