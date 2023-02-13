#!/bin/sh
#
# copy photos to archive
#
archiveImage=/Volumes/ImageBUs_2TB/image_Archive.sparsebundle
archiveD=/Volumes/image_Archive
archiveS=
apath
if mount | grep "on ${dpath}" > /dev/null; then
    sleep 10
    echo "hdiutil detach ${dpath}"
    hdiutil detach "${dpath}"
else
    echo "${dpath} is not mounted"
fi
time rsync -u -av --exclude ".DS_Store" /Volumes/iMacDataSSD/Pictures/Pictures_Roy/Originals/ /Volumes/Archive_SSD/archive/Pictures/Pictures_roy/Originals/
