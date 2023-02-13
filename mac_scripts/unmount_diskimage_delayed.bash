#!/bin/bash
iname=${1}
stime=10

echo "disk image dismount ..."
#
# check if disk is mounted
#
dpath="/Volumes/image_"$iname
if mount | grep "on ${dpath}" > /dev/null; then
    sleep 10
    echo "execute unmount diskimage ..."
    /Users/royboy/Scripts/unmount_imacdatassd.bash
else
    echo "${dpath} is not mounted"
fi
