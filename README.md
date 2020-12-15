# Personal Terraform environment

Create a `davidep.auto.tfvars` file, like the following:

    do_key   = "davidep"
    do_token = "secret"
    project  = "davidep"
    domain   = "dp.nethserver.net"

Create vm1

    $ terraform apply
