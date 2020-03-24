#!/bin/bash

# I reserved the following instance on 2011-03-09 for a 3 year term:
# Instance Type: t1.micro
# Operating System: Linux/UNIX
# Availability Zone: us-east-1d
# ID: 93bbbca2-221d-411a-8d44-90f9556cbf64 
export AVAIL_ZONE=us-east-1d
export INSTANCE_TYPE=t1.micro

# Canonical Lucid 64-bit EBSboot        us-east-1: ami-3202f25b
# Canonical Lucid 64-bit instance store us-east-1: ami-fa01f193
# Canonical Lucid 32-bit EBSboot        us-east-1: ami-3e02f257
# Canonical Lucid 32-bit instance store us-east-1: ami-7000f019
# N.B. an instance store AMI cannot be used on a t1.micro
# N.B. the m1.small type instance is 32-bit only
export AMI_ID=ami-3202f25b

export EC2_KEYS=~/.ec2
export EC2_PRIVATE_KEY=$EC2_KEYS/pk-E2QI4JNYCOY6QK7K6YKZTEIMXQ3AIMQE.pem
export EC2_CERT=$EC2_KEYS/cert-E2QI4JNYCOY6QK7K6YKZTEIMXQ3AIMQE.pem
export RSA_ID="$EC2_KEYS/id_rsa-pellie"
export GSG_KEYPAIR="pellie"

ssh-add $RSA_ID

echo "Starting $INSTANCE_TYPE instance with $AMI_ID AMI . . ."
export EC2_INSTANCE=`ec2-run-instances $AMI_ID -k $GSG_KEYPAIR -z $AVAIL_ZONE -t $INSTANCE_TYPE | tr '\t' '\n' | grep '^i-'`
echo "Waiting 40 seconds for instance $EC2_INSTANCE to start . . ."
sleep 40
export EC2_HOST=`ec2-describe-instances | grep $EC2_INSTANCE | tr '\t' '\n' | grep amazonaws.com`
echo "$EC2_INSTANCE has been assigned the hostname $EC2_HOST."

# ssh ubuntu@$EC2_HOST
