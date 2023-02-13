#!/bin/bash
iname=${1}

dpath="/Volumes/image_"$iname
cscript=/Users/royboy/Scripts/unmount_diskimage.bash
echo "Execute $cscript to insure unmount of ${dpath}..."
if mount | grep "on ${dpath}" > /dev/null; then
    echo "execute unmount diskimage ..."
    nohup $cscript ${dpath} &
else
    echo "${dpath} is not mounted"
fi
