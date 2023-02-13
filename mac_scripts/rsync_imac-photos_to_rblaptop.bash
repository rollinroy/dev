#!/bin/sh
#
# copy photos to archive
#
photosSrc=/Volumes/iMacDataSSD/Pictures/Pictures_Roy/Originals/
photosArchive=/Volumes/royboy/Pictures/Originals/
rsync -u -av --exclude ".DS_Store" --exclude "*.on1" --exclude "*.psd" --exclude "*.xmp" --exclude "*.onphoto"  ${photosSrc}/2021 ${photosArchive}
rsync -u -av --exclude ".DS_Store" --exclude "*.on1" --exclude "*.psd" --exclude "*.xmp" --exclude "*.onphoto"  ${photosSrc}/2022 ${photosArchive}
