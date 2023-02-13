#!/bin/sh
#
# copy photos to archive
#
photosSrc=/Volumes/iMacDataSSD/Pictures/Pictures_Roy/Originals/
photosArchive=/Volumes/Archive_SSD/archive/Pictures/Pictures_Roy/Originals/
time rsync -u -av --exclude ".DS_Store" ${photosSrc} ${photosArchive}
