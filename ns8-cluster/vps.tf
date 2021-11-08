
variable "images" {
  description = "Map host name code to OS image"
  default = {
    "fc" = "fedora-34-x64",
    "dn" = "debian-11-x64",
    "ub" = "ubuntu-21-04-x64"
  }
}

resource "digitalocean_vpc" "private_network" {
  for_each = tomap({ for region in distinct(values(var.nodes)) : region => region })
  name     = format("%s.%s-net.%s", terraform.workspace, each.key, var.domain)
  region   = each.key
}

resource "digitalocean_droplet" "vps" {
  for_each = var.nodes
  image    = var.images[substr(each.key, 0, 2)]
  name     = format("%s.%s", each.key, var.domain)
  region   = each.value
  size     = "s-1vcpu-1gb-intel"
  ipv6     = true
  vpc_uuid = digitalocean_vpc.private_network[each.value].id
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  user_data = templatefile("cloud-init.yml", {
    core_phash  = bcrypt(random_password.core[each.key].result)
    install_cmd = "curl https://raw.githubusercontent.com/NethServer/ns8-scratchpad/main/core/install.sh | bash",
    join_cmd    = "echo DONE",
  })
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

resource "random_password" "core" {
  for_each    = toset(keys(var.nodes))
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_special = 1
  min_numeric = 1
}

output "secrets" {
  description = "Generated passwords for the core user"
  value       = { for k in keys(var.nodes) : k => random_password.core[k].result }
}
