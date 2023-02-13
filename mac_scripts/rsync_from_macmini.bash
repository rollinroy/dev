#!/bin/sh
rem_mac="rb-macmini.local"
mnt_root="/Users/royboy/Volumes"
local_root="/Volumes/Archive"
rem_access="royboy:Portman007"

src_mounted="no"
#
# copy imac archive
#
rsync_folder="Rsync/Archive"
mnt_folder=$mnt_root"/imac_rsync_"$rsync_folder
mnt_remote="//"$rem_access"@"$rem_mac/$rsync_folder
mnt_info="//user:pwd@"$rem_mac/$rsync_folder

#
# check if local drive is up
#
local_dir=$local_root
if [ ! -d $local_dir ]; then
  echo $(date) : Error: $local_dir does not exist or is not mounted
  exit 1
fi
#
# see if remote mac is up
#
ping -o $rem_mac &> /dev/null
p_status=$?
if [ $p_status -ne 0 ]; then
  echo $(date) : Warning: $rem_mac is not available
  exit 0
else
  echo $(date) : Copying $mnt_remote files to $local_dir
fi
#
# mount macmini
#
if sudo mount | grep $rem_mac/$rsync_folder > /dev/null; then
    echo $(date) : $mnt_info is mounted
    mounted="yes"
else
    echo $(date) : $mnt_info is not mounted but will now mount
    if [ -d $mnt_folder ]; then
        echo $(date) : removing $mnt_folder
        rmdir $mnt_folder
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $mnt_folder
            exit 1
        fi
    fi
    mkdir -p $mnt_folder
#    echo debug: mount_afp afp:$mnt_remote $mnt_folder
    mount_afp afp:$mnt_remote $mnt_folder
    m_status=$?
    if [ $m_status -ne 0 ]; then
#        rmdir $mnt_folder
        exit 1
    fi
    mounted="no"
fi
#
# copy files
#
echo $(date) : copying files from $mnt_info to $local_dir
rsync -av --exclude ".*/" $mnt_folder/ $local_dir/ > ~/log/rsync_$rsync_folder.txt
#
# unmount if needed
#
if [ "$mounted" == "no" ]; then
   echo $(date) : Unmounting $mnt_folder
   umount $mnt_folder
   if [ -d $mnt_folder ]; then
       echo $(date) : removing $mnt_folder
       rmdir $mnt_folder
       r_status=$?
       if [ $r_status -ne 0 ]; then
           echo $(date) : Error: Cannot remove $mnt_folder
           exit 1
       fi
   fi
else
   echo $(date) : Keeping $mnt_folder mounted
fi

echo $(date) : All copying complete
