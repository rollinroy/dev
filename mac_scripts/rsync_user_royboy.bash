#!/bin/sh
#
# copy imac work folders
#
rem_mac="macair-ssd.local"
rem_folder="/Users/royboy/work/uw"
local_root="/Users/royboy/work"
pvt_key="~/.ssh/macair-ssd"
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
rsync -e "ssh -i $pvt_key" --exclude ".DS_Store" $rem_mac:$rem_folder $local_root > ~/log/rsync_work.txt
echo $(date) : Copying  $rem_mac:$rem_folder complete
