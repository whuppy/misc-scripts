#!/bin/bash

VOLUME_ID=`cat /mnt/deluge/deluge-workspace/volume-id.txt`
echo $VOLUME_ID
sudo umount /mnt/deluge
aws ec2 detach-volume --volume-id $VOLUME_ID
sleep 10
aws ec2 delete-volume --volume-id $VOLUME_ID
echo "Done."
