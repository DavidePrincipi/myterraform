
variable "images" {
  description = "Map host name code to OS image"
  default = {
    "fc" = "fedora-34-x64",
    "dn" = "84043396",
    "ub" = "ubuntu-21-04-x64"
  }
}

# Generate a priv/pub key pair for the runner user.
# This is required to locally log in as root from a runner session.
# A simple "sudo" escalation does not set up the XDG session as Podman likes.
resource "tls_private_key" "runner_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "digitalocean_droplet" "vps" {
  for_each           = var.nodes
  image              = var.images[substr(each.key, 0, 2)]
  name               = format("%s.%s", each.key, var.domain)
  region             = each.value
  size               = "s-2vcpu-2gb-intel"
  ipv6               = false
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  user_data          = templatefile("cloud-init.yml", {
    github_token = var.github_token,
    github_user = var.github_user,
    github_repo = var.github_repo,
    runner_privk = tls_private_key.runner_key.private_key_pem
    runner_pubk = tls_private_key.runner_key.public_key_openssh
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
