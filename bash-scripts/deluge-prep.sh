#!/bin/bash

# Create 20G volume
AVAIL_ZONE="us-east-1c"
VOL_SIZE="20"
CREATE_RESULT=`aws ec2 create-volume --availability-zone "$AVAIL_ZONE" --no-encrypted --size "$VOL_SIZE"`
VOLUME_ID=`echo $CREATE_RESULT | jq .VolumeId | sed 's/\"//g'`
echo "Created volume, Volume ID = $VOLUME_ID"

echo "Sleeping for 10 seconds . . ."
sleep 10

# Attach
#INSTANCE_ID="i-0bb91eb05dcebf5a5"
INSTANCE_ID="i-0def69f8d3058ae52"
# AWS calls the device /dev/sdf, but inside the machine it's called /dev/xvdf.
AWS_DEVICE_ID="/dev/sdf"
MACHINE_DEVICE_ID="/dev/xvdf"
ATTACH_RESULT=`aws ec2 attach-volume --instance-id $INSTANCE_ID --volume-id $VOLUME_ID --device $AWS_DEVICE_ID`
echo $ATTACH_RESULT

echo "Sleeping for 10 seconds . . ."
sleep 10

# Check on attachment status:
aws ec2 describe-volumes --volume-ids $VOLUME_ID

# Partition and Format:
# deluge-volume-partition-info.txt was generated via sfdisk -d $MACHINE_DEVICE_ID on a properly partitioned volume:
sudo sfdisk $MACHINE_DEVICE_ID < deluge-volume-partition-info.txt
PARTITION_ID="${MACHINE_DEVICE_ID}1"
sudo mkfs.ext3 -L "deluger" $PARTITION_ID

# Mount:
sudo mount $PARTITION_ID /mnt/deluge

# Create directories and set ownership:
for i in completed downloads torrent-copies torrent-to-do torrent-files ; do
	sudo mkdir -p /mnt/deluge/deluge-workspace/$i
done
sudo chown -R ubuntu /mnt/deluge/deluge-workspace

echo $VOLUME_ID > /mnt/deluge/deluge-workspace/volume-id.txt

ls -R /mnt/deluge/deluge-workspace

# Now you're ready to:
# deluge -u web -L info
echo  "Now you're ready to: deluge -u web -L info"

