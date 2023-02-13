#!/bin/bash
# superduper will attempt to unmount the disk image in destination path (dpath)
# after executing this custom script.  as of this time (5/30/2020),
# the disk image is still mounted.  if this script dismounts the disk image, then
# sd's attempt to unmount the disk image will generate an error because
# the disk has been unmounted.  so, just call another script in the background
# that sleeps and then unmounts the disk image after sd has completed.
#
dpath=$1
if mount | grep "on $dpath" > /dev/null; then
    sleep 10
    echo "umount $dpath ..." > /tmp/sd_check.txt 2>&1
    sudo umount $dpath
else
    echo "$dpath is not mounted" > /tmp/sd_check.txt 2>&1
fi
