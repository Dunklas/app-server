# app-server

Contains infrastructure, etc for my EC2 server where I host personal projects.
Infrastructure is defined with Terraform.

## First time deploy

Before running the pipeline for this repository, there are some things you must do.

 - Make sure an S3 bucket exist for storing terraform state, and that the bucket name is defined as `TF_STATE_BUCKET` in the [pipeline](.github/workflows.main.yml)
 - Make sure repository secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exist, and corresponds to an account with access to above created S3 bucket, and to deploy infrastructure (these credentials will be used by terraform)
 - Create a key pair with the private key in PEM format (you can do this by running `ssh-keygen -m PEM`)
    - Add the public key as repository secret `SSH_PUBLIC_KEY`
    - Base64 encode the private key and add it as repository secret `SSH_PRIVATE_KEY`
    - This will be used to authenticate to the machine via ssh, for configuring it by running ansible playbooks
 - Add a hosted zone id to repository secret `HOSTED_ZONE_ID`
    - Used for automatically creating DNS record for any server_names in `servers.json`

Now you can run the pipeline.

## Adding a service to the server

To add a new service to the server:

1. Start a docker container for the service on the app-server
    - Make sure the docker container is exposed on a port that isn't already used by some other service
2. Update `servers.json` with a new entry, where the upstream port is the port that the docker container exposes
    - This file is used in pipeline in order to have terraform create a DNS record for it
    - This file is also used by Frontman to generate nginx configuration
    - If https, it's also used in pipeline to have automatically get a HTTPS certificate from letsencrypt
