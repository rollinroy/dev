#!/bin/sh
#
# copy imac user folders
#
time rsync -u -av -e "ssh -i ~/.ssh/rb-imac.pem" --exclude "royboy/Volumes" --exclude "royboy/.Trash" --exclude "royboy/.TemporaryItems" --exclude "royboy/Movies" --exclude ".Trash*" --exclude "royboy/Documents/Davinci*" --exclude ".DS_Store" --exclude "royboy/Library" /Users/royboy royboy@rb-laptop.local:/Users/royboy/rb-imac
