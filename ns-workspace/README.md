# Personal Terraform NethServer workspace

1. Create a `davidep.auto.tfvars` file, like the following:

       sshkeys  = ["davidep"]
       do_token = "secret"
       project  = "davidep"
       domain   = "dp.nethserver.net"

2. Create and select a new workspace `cluster0`

       terraform workspace new cluster0

3. Create two nodes for `cluster0`

       terraform apply -var 'nodes={"dn1":"ams3","fc2":"sfo3"}'
       # -> dn1.dp.nethserver.net
       # -> fc2.dp.nethserver.net

4. Add another node to it:

       terraform apply -var 'nodes={"dn1":"ams3","fc2":"sfo3","fc3":"lon1"}'
       # -> fc3.dp.nethserver.net

5. Destroy the cluster

       terraform destroy -var 'nodes={}'

To work with multiple cluster instances just add more Terraform
workspaces. E.g.:

    terraform workspace new cluster1
    terraform apply -var 'nodes={"fc5":"ams3","fc6":"sfo3","fc7":"sgp1"}'
    terraform workspace select cluster0
    terraform destroy -var 'nodes={"dn1":"ams3","fc2":"sfo3"}'

## The `nodes` variable

The `nodes` variable is a map. Each item represents a cluster node.

- The item _key_ selects the OS type. Specify it followed by a number:

  * `dn` is for Debian 11
  * `cs` is for CentOS Stream 9
  * `nscom` is for NethServer 7 Community
  * `nsent` is for NethServer 7 Enterprise

- The item _value_ selects the VPS region. Refer to `doctl compute region list` output for
  a list of valid region codes.

## Install alternative images

Set `install_url` to download an alternative install script. For instance

    terraform apply -var nodes='{"cs1":"ams3"}' -var install_url=http://myinstall.io/ns8-install.sh

If the resource is not found, install is skipped

Set `install_args` to a space-separated list of image URLs. Those image override the default ones, for instance:

    terraform apply -var nodes='{"cs1":"ams3"}' -var install_args="ghcr.io/nethserver/core:newfeature ghcr.io/nethserver/traefik:newfeature"

## Droplet size

Set the `dropletsz` variable to a DigitalOcean size slug to change the
droplet size (default `s-2vcpu-2gb-intel`). List the available slugs
with `doctl compute size list`.

    terraform apply -var nodes='{"rl1":"ams3"}' -var dropletsz=s-2vcpu-4gb

## Enable swap space

Set the `swapsz` variable to a positive integer to configure disk swap
memory. One unit corresponds to one "Mebibyte" (1024*1024 bytes).

## Kernel updates

The NS8 install applies all pending OS updates, kernel included, and
cloud-init reboots the node at the end of the procedure. For a faster
provisioning set `kernel_update=false`: kernel, kmod, microcode and grub2
packages are excluded from DNF updates (no effect on Debian) and no
reboot occurs.

    terraform apply -var nodes='{"rl1":"ams3"}' -var kernel_update=false

## Acme staging environment

Set `acme_staging=false` to disable the ACME staging environment and use
the production one.

## Create the cluster and register it on my.nethesis.it

Set `my_token` to a my.nethesis.it API token (`myk_...`) and
`my_organization_id` to the Customer ID the system belongs to.
For example put in your personal `.auto.tfvars` file:

    my_token = "myk_..."
    my_organization_id = "yxxhqrlc7sjd"

For each node Terraform creates a my.nethesis.it system named after the
node FQDN under `my_organization_id`, and passes its secret to cloud-init.
The node then runs `create-cluster` with the default admin credentials and
registers the cluster with `set-subscription`.

    terraform apply -var nodes='{"rl1":"ams3"}'

`my_url` selects the my.nethesis.it instance (default is the beta one).
The systems are deleted from my.nethesis.it on `terraform destroy`, so
keep `my_token` set when destroying.
