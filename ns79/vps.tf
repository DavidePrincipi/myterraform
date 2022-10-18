
variable "images" {
  description = "Map host name code to OS image"
  default = {
    "nscom" = "nethserver-7.9.2009",
    "nsent" = "nethserver-enterprise-7.9.2009",
  }
}

data "digitalocean_image" "nsimg" {
  for_each = var.nodes
  name     = var.images[substr(each.key, 0, 5)]
}

data "digitalocean_image" "image_nsent" {
  name = "nethserver-enterprise-7.9.2009"
}

resource "digitalocean_droplet" "vps" {
  for_each           = var.nodes
  image              = data.digitalocean_image.nsimg[each.key].id
  name               = format("%s.%s", each.key, var.domain)
  region             = each.value
  size               = "s-1vcpu-1gb-intel"
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

resource "digitalocean_project_resources" "vps" {
  project   = data.digitalocean_project.default.id
  resources = [for hpx, rgn in var.nodes : digitalocean_droplet.vps[hpx].urn]
}

resource "digitalocean_record" "vps_ipv4" {
  for_each = var.nodes
  type     = "A"
  domain   = data.digitalocean_domain.default.name
  value    = digitalocean_droplet.vps[each.key].ipv4_address
  name     = each.key
  ttl      = 300
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
  sensitive   = true
}
