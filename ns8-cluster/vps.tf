
locals {
  //Map host name code to OS image
  images = {
    "fc" = "fedora-34-x64",
    "cs" = "centos-stream-9-x64",
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
  image    = local.images[substr(each.key, 0, 2)]
  name     = format("%s.%s", each.key, var.domain)
  region   = each.value
  size     = "s-2vcpu-2gb-intel"
  ipv6     = substr(each.key, 0, 2) == "cs" ? false : true
  vpc_uuid = digitalocean_vpc.private_network[each.value].id
  ssh_keys = [
    for k in var.sshkeys : data.digitalocean_ssh_key.rootpkey[k].id
  ]
  user_data = templatefile("cloud-init.yml", {
    install_branch = var.install_branch == "" ? "main" : var.install_branch
    pull_branch    = var.install_branch
    pull_modules   = var.install_branch == "" ? "" : var.install_modules
    sshkeys        = [for k in var.sshkeys : data.digitalocean_ssh_key.rootpkey[k].public_key]
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

