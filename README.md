# app-server

Contains infrastructure, etc for my EC2 server where I host personal projects.
Infrastructure is defined with Terraform.

## First time deploy

With the deployed infrastructure, I also define a public key which will have access to ssh into the machine.
The public key is currently hardcoded into the terraform configuration. Therefore, on first deployment (and if you lose the corresponding private key), you will need to generate a key pair, and update the public key in the `aws_key_pair` resource.

To generate a new key pair, run:
- `ssh-keygen -m PEM`.
