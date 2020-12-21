resource "digitalocean_droplet" "vps" {
  image              = var.nsent ? data.digitalocean_image.image_nsent.id : data.digitalocean_image.image_nscom.id
  name               = var.host
  region             = var.region
  size               = "s-1vcpu-1gb"
  ipv6               = false
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    type  = "ssh"
    user  = "root"
    host  = self.ipv4_address
    agent = true
  }

  provisioner "file" {
    content     = random_password.root.result
    destination = "/root/.pw"
  }

  provisioner "remote-exec" {
    inline = [
      "passwd --stdin root < /root/.pw",
      "rm -f /root/.pw"
    ]
  }
}

variable "region" {
  description = "DO droplet region"
  default = "ams3"
}

variable "nsent" {
  type = bool
  description = "Use or not the Enterprise base image"
  default = false
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

resource "random_password" "root" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_special = 1
  min_numeric = 1
}

output "root_password" {
  description = "Random root password"
  value       = random_password.root.result
}
