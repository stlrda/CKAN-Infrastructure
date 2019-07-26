variable "vpc_name" {
  default = "default-vpc-name"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

variable "hosted_zone" {}

variable "rds_password" {}

variable "datastore_ro_password" {
  default = datastore_ro_password
}

variable "admin_ip" {}