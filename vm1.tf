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

  connection {
    type     = "ssh"
    user     = "root"
    host     = self.ipv4_address
    agent    = true
  }

  provisioner "file" {
    content = random_password.root.result
    destination = "/root/.pw"
  }

  provisioner "remote-exec" {
    inline = [
      "passwd --stdin root < /root/.pw",
      "rm -f /root/.pw"
    ]
  }
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

resource "random_password" "root" {
  length = 16
  min_lower = 1
  min_upper = 1
  min_special = 1
  min_numeric = 1
}

output "root_password" {
  description = "Random root password"
  value = random_password.root.result
}
