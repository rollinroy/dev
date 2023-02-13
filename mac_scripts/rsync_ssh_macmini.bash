#!/bin/sh
#
# copy macmini work folders
#
rem_mac="rb-macmini.local"
rem_folder="/Users/royboy/work"
local_root="/Users/royboy"
pvt_key="~/.ssh/rb-imac"
#
# see if remote mac is up
#
ping -o $rem_mac &> /dev/null
p_status=$?
if [ $p_status -ne 0 ]; then
  echo $(date) : Warning: $rem_mac is not available
  exit 0
fi
#
# copy files
#
echo $(date) : Copying $rem_mac:$rem_folder files to $local_root
rsync -e "ssh -i $pvt_key" -av --exclude ".*/" --exclude ".DS_Store" $rem_mac:$rem_folder $local_root > ~/log/rsync_work.txt
echo $(date) : Copying  $rem_mac:$rem_folder complete

#
# copy macmini Scripts
#
rem_folder="/Users/royboy/Scripts"
local_root="/Users/royboy"
#
# copy files
#
echo $(date) : Copying $rem_mac:$rem_folder files to $local_root
rsync -e "ssh -i $pvt_key" -av --exclude ".*/" --exclude ".DS_Store" $rem_mac:$rem_folder $local_root > ~/log/rsync_scripts.txt
echo $(date) : Copying  $rem_mac:$rem_folder complete
