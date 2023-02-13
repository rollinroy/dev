#!/bin/bash
script=${0}
svol=${1}
spath=${2}
dvol=${3}
dpath=${4}
bscript=${5}

# superduper will attempt to unmount the disk image in destination path (dpath)
# after executing this custom script.  as of this time (5/30/2020),
# the disk image is still mounted.  if this script dismounts the disk image, then
# sd's attempt to unmount the disk image will generate an error because
# the disk has been unmounted.  so, just call another script in the background
# that sleeps and then unmounts the disk image after sd has completed.
#
echo "mount diskimage ${dpath}..."
hdiutil attach /Volumes/ImageBUs_2TB/image_Archive.sparsebundle/
