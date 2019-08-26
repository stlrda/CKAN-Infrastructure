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

variable "rds_username" {}

variable "datastore_readonly_password" {
  default = "datastore_ro_password"
}

variable "admin-cidr-blocks" {}

variable "ckan_admin" {

}
variable "ckan_admin_password" {
  description = ""
}