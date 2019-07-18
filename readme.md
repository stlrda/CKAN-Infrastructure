Instructions for setting up ckan infrastructure on AWS


###### Setup terraform binary

1. Terraform uses the AWS CLI, install that: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
1. Make sure you configure the CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
1. Install terraform here: 
https://learn.hashicorp.com/terraform/getting-started/install.html

quick reference on mac with homebrew: 
`brew install terraform`



###### Setup and Use

1. In console, move to `/infrastructure` directory
1. Copy the  `terraform.tfvars.example` to `terraform.tfvars` and fill out with your choices.
1. Run `terraform init` to initalize local terrform state
1. After any infrastructure changes, run `terraform apply`

###### Determine the Public Facing URL
1. Assume that your domain is hosted in route53
1. get the Hosted Zone ID such as `A5GJ576DARR2YZ`
1. update the hosted_zone in your local `terraform.tfvars` 
1. this will create a DNS record to generate a SSL Certificate for ckan

###### Optional: Remote State

(This is not needed, default will store state locally where terraform binary runs.)

1. Rename `backend.tf.example` to `backend.tf`
1. Manually create an S3 bucket to store state. Terraform recommends to enable versioning in bucket.
1. Manually create a DynamoDB table to store lock state. Primary partition key of table MUST BE ``LockID`` (String)
1. Specify S3 bucket and DynamoDB table in `backend.tf` 
1. Ensure your IAM user has access to S3 bucket and DynamoDB table
1. Run `terraform init`
1. Your state and lock is now stored remotely

###### Optional: Opsworks SSH Access

(This is not required: Opsworks can manage public keys on instances)

1. import some IAM users in Opsworks
1. Add public SSH keys for users that will have SSH access
1. grant access to the instances in Opsworks for the instnaces
1. get ssh instructions from Opsworks console page