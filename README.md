# app-server

Contains infrastructure, etc for my EC2 server where I host personal projects.
Infrastructure is defined with Terraform.

## First time deploy

Before running the pipeline for this repository, there are some things you must do.

 - Make sure an S3 bucket exist for storing terraform state, and that the bucket name is defined as TF_STATE_BUCKET in the [pipeline](.github/workflows.main.yml)
 - Make sure repository secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exist, and corresponds to an account with access to above created S3 bucket, and to deploy infrastructure (these credentials will be used by terraform)
 - Create a key pair, and add the public key to the `aws_key_pair` resource in [main.tf](iac/main.tf) (the corresponding private key will have access to ssh into the machine)

Now you can run the pipeline.
