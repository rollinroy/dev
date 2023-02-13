#!/bin/sh
#
# copy imac user folders
#
time rsync -u -av -e "ssh -i ~/.ssh/rb-imac.pem" --exclude ".DS_Store" /Volumes/iMacDataSSD/Pictures/Pictures_Roy/Originals/2021/ royboy@rb-laptop.local:/Users/royboy/Pictures/Originals/2021/
