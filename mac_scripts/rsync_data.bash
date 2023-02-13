#!/bin/sh
# 500GB_SSD
hdiutil attach -mountpoint /Volumes/image_500GB_SSD /Volumes/ImageBUs_2TB/image_500GB_SSD.sparsebundle/
time rsync -u -av --exclude ".*" /Volumes/500GB_SSD/ /Volumes/image_500GB_SSD/ > /tmp/rsync_500GB.log
umount /Volumes/image_500GB_SSD

# iMacDataSSD
hdiutil attach -mountpoint /Volumes/iMacDataSSD /Volumes/ImageBUs_2TB/image_iMacDataSSD.sparsebundle/
time rsync -u -av --exclude ".*" /Volumes/iMacDataSSD/ /Volumes/image_iMacDataSSD/ > /tmp/rsync_iMacData.log
umount /Volumes/iMacDataSSD

# helpful trouble shooting
# _10046$ hdiutil attach -noverify -nomount /Volumes/ImageBUs_2TB/image_500GB_SSD.sparsebundle/
