resource "digitalocean_droplet" "vm1" {
  image              = data.digitalocean_image.image_nscom.id
  name               = "vm1"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
  ipv6               = false
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
}

resource "digitalocean_project_resources" "vm1" {
  project = data.digitalocean_project.default.id
  resources = [
    digitalocean_droplet.vm1.urn
  ]
}

resource "digitalocean_record" "vm1_ipv4" {
  type   = "A"
  domain = data.digitalocean_domain.default.name
  value  = digitalocean_droplet.vm1.ipv4_address
  name   = "vm1"
  ttl    = 300
}
