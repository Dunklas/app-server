variable "key_pair_name" {
  type        = string
  description = "Name of the aws_key_pair associated with ec2 instance."
}

variable "key_pair_public_key" {
  type        = string
  description = "Public key of the aws_key_pair associated with ec2 instance. Corresponding private key will have SSH access to the ec2 instance."
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Id of hosted zone where DNS records for sub_domains will be created."
}

variable "sub_domains" {
  type        = list(string)
  default     = []
  description = "List of sub domains that will point to the ec2 instance"
}
