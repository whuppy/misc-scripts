#!/bin/bash
# This was written to be run from samson.
# I brought it over to aws to adapt it for local automatic mounting of itunes

export INSTANCE_ID=`aws ec2 describe-instances  --output json --filter "Name=tag:Name,Values=Pinkie Xenial" | jq .Reservations[].Instances[].InstanceId | sed s/\"//g`
echo $INSTANCE_ID

export INSTANCE_AVAIL_ZONE=`aws ec2 describe-instances  --output json --filter "Name=tag:Name,Values=Pinkie Xenial" | jq .Reservations[].Instances[].Placement.AvailabilityZone | sed s/\"//g`
echo $INSTANCE_AVAIL_ZONE

export SNAPSHOT_NAME="Lizard Backup"
export SNAPSHOT_ID=`aws ec2 describe-snapshots --filter "Name=tag:Name,Values=${SNAPSHOT_NAME}" --output json | jq .Snapshots[].SnapshotId | sed s/\"//g`
echo $SNAPSHOT_ID

export VOLUME_ID=`aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --availability-zone $INSTANCE_AVAIL_ZONE --output json | jq .VolumeId | sed s/\"//g`
echo $VOLUME_ID

echo Sleeping for 60 seconds while volume becomes available . . .
sleep 60

export DEVICE_ID=/dev/xvdf
export PARTITION_ID=${DEVICE_ID}1
export ATTACH=`aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device $DEVICE_ID`
echo $ATTACH

echo "Sleeping 10 seconds while volume attaches to instance . . ."
sleep 10

export REMOTE_USER=ubuntu
export REMOTE_HOST=aws.frdmrt.org
export REMOTE_MOUNT=/mnt/lizard
eval `ssh-agent`
export ID_RSA=/home/schmelzer/.aws/id_rsa-pellie
ssh-add $ID_RSA
ssh ${REMOTE_USER}@${REMOTE_HOST} "sudo mount ${PARTITION_ID} ${REMOTE_MOUNT}"

SOURCE_DIR=/mnt/jesse/lzardb-backup-target/
TARGET_DIR=${REMOTE_MOUNT}/lzardb-backup-target/
rsync -av ${SOURCE_DIR} ${REMOTE_USER}@${REMOTE_HOST}:${TARGET_DIR}

ssh ${REMOTE_USER}@${REMOTE_HOST} "sudo umount $REMOTE_MOUNT"
export DETACH=`aws ec2 detach-volume --volume-id ${VOLUME_ID}`
echo $DETACH

export NEW_SNAPSHOT_ID=`aws ec2 create-snapshot --volume-id ${VOLUME_ID} --description "Lizard Backup" --output json | jq .SnapshotId | sed s/\"//g`
echo $NEW_SNAPSHOT_ID

echo "Sleeping for 60 seconds before deleting volume . . ."
sleep 60

export VOLUME_DELETE=`aws ec2 delete-volume --volume-id ${VOLUME_ID}`
echo ${VOLUME_DELETE}
