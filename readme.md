Instructions for setting up CKAN infrastructure on AWS

###### Setup terraform binary
1. Terraform uses the AWS CLI, install that: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
1. Make sure you configure the CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
1. Install terraform here: 
https://learn.hashicorp.com/terraform/getting-started/install.html

quick reference on Mac with homebrew: 
`brew install terraform`

###### Setup and Use
1. In console, move to `/infrastructure` directory
1. Copy the  `terraform.tfvars.example` to `terraform.tfvars` and fill out with your choices.
1. Run `terraform init` to initialize local terraform state
1. After any infrastructure changes, run `terraform apply`

###### Determine the Public Facing URL
1. Assume that your domain is hosted in route53
1. Get the Hosted Zone ID such as `A5GJ576DARR2YZ`
1. Update the hosted_zone in your local `terraform.tfvars` 
1. This will create a DNS record to generate a SSL Certificate for CKAN

###### Set your administrative IP list
1. The list takes CIDR block ranges in the format of `a.b.c.d/z`. see: https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
1. if you want to add a single IP address, the suffix is `/32` i.e. `1.2.3.4/32`
1. Add all wnated IPs in you `terraform.tfvars` file

###### One-Time Non-Terraform Setup for Opsworks SSH Access
Opsworks manages public SSH keys on instances for access by your team. Instances in the autoscale group are added to opsworks.

1. (note: you must connect from one of the administrative ips)
1. Import IAM users you want to give access to in Opsworks (https://docs.aws.amazon.com/opsworks/latest/userguide/opsworks-security-users-manage-import.html)
1. If you don't already have a public/private keypair set up, create one using this guide. Adding the SSH key to the agent is optional. https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
1. Copy and paste the contents of public SSH key (NOT the key.PEM file) to the opsworks user (https://docs.aws.amazon.com/opsworks/latest/userguide/security-settingsshkey.html)
1. Grant access to the instances in Opsworks for the instances
1. Get ssh instructions from Opsworks web console page

###### Required One-Time Non-Terraform Setup for EFS
EFS (Elastic File System) is used to store files that are uploaded to CKAN and any site configuration changes. The directory is mounted on all ECS Cluster member hosts at `/mnt/efs/`. Hosts reading contents of the directory are pointed to a network volume shared among all hosts. 

The mounted EFS directory must be owned by user/group id `92` - which is ckan in the container. Without this, the application inside the container cannot write to the mounted EFS volume on the host.

SSH in to any ECS host (listed in opsworks), and run `sudo chown -R 92:92 /mnt/efs/ckan`. This only needs to be done once per EFS filesystem.

###### Required One-Time Non-Terraform Setup for Database
The RDS (Relational Database Service) database needs to be initialized with a user and database. Terraform will generate an empty database. Log in to the database using a SQL tool (such as pgadmin) and run the SQL in `templates/rds-bootstrap.sh` to create the `datastore_ro` role and the `datastore` database. 

###### Optional: Remote State
(This is not needed, default will store state locally where terraform binary runs.)

1. Rename `backend.tf.example` to `backend.tf`
1. Manually create an S3 bucket to store state. Terraform recommends to enable versioning in bucket.
1. Manually create a DynamoDB table to store lock state. Primary partition key of table MUST BE ``LockID`` (String)
1. Specify S3 bucket and DynamoDB table in `backend.tf` 
1. Ensure your IAM user has access to S3 bucket and DynamoDB table
1. Run `terraform init`
1. Your state and lock is now stored remotely