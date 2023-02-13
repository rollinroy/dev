#!/bin/bash
script=${0}
svol=${1}
spath=${2}
dvol=${3}
dpath=${4}
bscript=${5}

#
imageName="/Volumes/image_iMacDataSSD"
echo "unmount  $imageName ..."
sudo umount $imageName
