
locals {
  //Map host name code to OS image
  images = {
    "cs"    = "9 Stream x64",
    "dn"    = "12 x64",
    "rl"    = "9 x64",
    "al"    = "AlmaLinux 9",
    "nscom" = "nethserver-7.9.2009",
    "nsent" = "nethserver-enterprise-7.9.2009",
  }

  // Select the cloud init template for each image
  ci_template = {
    "cs"    = "cloud-init-ns8.yml",
    "dn"    = "cloud-init-ns8.yml",
    "rl"    = "cloud-init-ns8.yml",
    "al"    = "cloud-init-ns8.yml",
    "nscom" = "cloud-init-ns7.yml",
    "nsent" = "cloud-init-ns7.yml",
  }

  // Enable IPv6 if the image supports it
  ipv6_enabled = {
    "cs"    = false,
    "dn"    = true,
    "rl"    = true,
    "al"    = true,
    "nscom" = false,
    "nsent" = false,
  }
}

data "digitalocean_image" "nsimg" {
  for_each = var.nodes
  name     = local.images[trim(each.key, "0123456789")]
  source   = "all"
}

resource "digitalocean_vpc" "private_network" {
  for_each = tomap({ for region in distinct(values(var.nodes)) : region => region })
  name     = format("%s.%s-net.%s", terraform.workspace, each.key, var.domain)
  region   = each.key
}

resource "digitalocean_droplet" "vps" {
  for_each = var.nodes
  image    = data.digitalocean_image.nsimg[each.key].id
  name     = format("%s.%s", each.key, var.domain)
  region   = each.value
  size     = "s-2vcpu-2gb-intel"
  ipv6     = local.ipv6_enabled[trim(each.key, "0123456789")]
  vpc_uuid = digitalocean_vpc.private_network[each.value].id
  ssh_keys = [
    for k in var.sshkeys : data.digitalocean_ssh_key.rootpkey[k].id
  ]
  user_data = templatefile(local.ci_template[trim(each.key, "0123456789")], {
    install_url   = var.install_url
    install_args  = var.install_args
    swapsz        = var.swapsz
    acme_staging  = var.acme_staging
    root_password = var.root_password != "" ? var.root_password : random_password.root.result
    sshkeys       = [for k in var.sshkeys : data.digitalocean_ssh_key.rootpkey[k].public_key]
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

resource "digitalocean_record" "vps_webtop" {
  for_each = var.nodes
  type     = "CNAME"
  domain   = data.digitalocean_domain.default.id
  value    = format("%s.", digitalocean_droplet.vps[each.key].name)
  name     = format("webtop%s", trim(each.key, "abcdefghijklmnopqrstuvwxyz"))
  ttl      = 300
}

resource "digitalocean_record" "vps_nextcloud" {
  for_each = var.nodes
  type     = "CNAME"
  domain   = data.digitalocean_domain.default.id
  value    = format("%s.", digitalocean_droplet.vps[each.key].name)
  name     = format("nextcloud%s", trim(each.key, "abcdefghijklmnopqrstuvwxyz"))
  ttl      = 300
}

resource "digitalocean_record" "vps_dokuwiki" {
  for_each = var.nodes
  type     = "CNAME"
  domain   = data.digitalocean_domain.default.id
  value    = format("%s.", digitalocean_droplet.vps[each.key].name)
  name     = format("dokuwiki%s", trim(each.key, "abcdefghijklmnopqrstuvwxyz"))
  ttl      = 300
}

resource "digitalocean_record" "vps_passwordcname" {
  for_each = var.nodes
  type     = "CNAME"
  domain   = data.digitalocean_domain.default.id
  value    = format("%s.", digitalocean_droplet.vps[each.key].name)
  name     = format("password%s", trim(each.key, "abcdefghijklmnopqrstuvwxyz"))
  ttl      = 300
}

resource "digitalocean_record" "vps_roundcube" {
  for_each = var.nodes
  type     = "CNAME"
  domain   = data.digitalocean_domain.default.id
  value    = format("%s.", digitalocean_droplet.vps[each.key].name)
  name     = format("roundcube%s", trim(each.key, "abcdefghijklmnopqrstuvwxyz"))
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
