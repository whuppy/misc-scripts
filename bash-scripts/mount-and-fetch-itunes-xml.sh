#!/bin/bash
# requires the most recent iTunes snapshot to be tagged Freshness:current

export INSTANCE_ID=`aws ec2 describe-instances  --output json --filter "Name=tag:Name,Values=Pinkie Xenial" | jq .Reservations[].Instances[].InstanceId | sed s/\"//g`
echo $INSTANCE_ID

export INSTANCE_AVAIL_ZONE=`aws ec2 describe-instances  --output json --filter "Name=tag:Name,Values=Pinkie Xenial" | jq .Reservations[].Instances[].Placement.AvailabilityZone | sed s/\"//g`
echo $INSTANCE_AVAIL_ZONE

export SNAPSHOT_ID=`aws ec2 describe-snapshots --filter "Name=tag:Freshness,Values=current" --output json | jq .Snapshots[].SnapshotId | sed s/\"//g`
echo $SNAPSHOT_ID

export VOLUME_ID=`aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --availability-zone $INSTANCE_AVAIL_ZONE --output json | jq .VolumeId | sed s/\"//g`
echo $VOLUME_ID

date
echo Sleeping for 60 seconds while volume becomes available . . .
sleep 60

export DEVICE_ID=/dev/xvdf
export PARTITION_ID=${DEVICE_ID}1
export ATTACH=`aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device $DEVICE_ID`
echo $ATTACH

date
echo "Sleeping 10 seconds while volume attaches to instance . . ."
sleep 10

export MOUNT_POINT=/mnt/itunes
sudo mount ${PARTITION_ID} ${MOUNT_POINT}

export LIB_XML_FILE="${MOUNT_POINT}/itunes-rsync/iTunes/iTunes Library.xml"
echo "Copying ${LIB_XML_FILE} to ~/documents/itunage/ . . ."
cp "${LIB_XML_FILE}" ~/documents/itunage/

sudo umount ${MOUNT_POINT}
export DETACH=`aws ec2 detach-volume --volume-id ${VOLUME_ID}`
echo $DETACH

date
echo "Sleeping for 60 seconds while volume detaches . . ."
sleep 60

export VOLUME_DELETE=`aws ec2 delete-volume --volume-id ${VOLUME_ID}`
echo ${VOLUME_DELETE}
