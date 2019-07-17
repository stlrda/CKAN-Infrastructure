Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
# configure EFS mount
repo_update: true
repo_upgrade: all

packages:
- amazon-efs-utils

runcmd:
- mkdir -p ${efs_directory}
- echo "${efs_filesystem_id}:/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

yum install aws-cli -y
aws opsworks register --use-instance-profile --infrastructure-class ec2 --region ${region} --stack-id ${stack_id} --local

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# this script causes the instance running it to join the ECS cluster
# {cluster_name} is specified in terraform before the file is sent over to the instance to run on first boot
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config

--==BOUNDARY==--
