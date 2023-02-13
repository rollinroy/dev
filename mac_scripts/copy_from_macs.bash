#!/bin/sh
rem_mac="rb-macair.local"
mnt_root="/Users/royboy/Volumes"
mnt_folder=$mnt_root"/macair_royboy"
dst_folder="/Volumes/MandM/FromMacAir/royboy/Documents"
rem_access="royboy:Portman007"

dst_mounted="no"
#
# backuqp imac docs - set sudo mount name and sudo mount if needed
# for stuff on nas_imac_copy
#
src_folder="/royboy/Documents"
mnt_src="//"$rem_access"@"$rem_mac$src_folder
mnt_psrc="//user:pwd@"$rem_mac$src_folder
#
# see if remote mac is up
#
ping -o $rem_mac &> /dev/null
p_status=$?
if [ $p_status -ne 0 ]; then
  echo $(date) : Warning: $rem_mac is not available
  exit 0
else
  echo $(date) : Copying files from $rem_mac
fi
#
# mount
#
if sudo mount | grep $mnt_src > /dev/null; then
    echo $(date) : $mnt_psrc is mounted
    mounted="yes"
else
    echo $(date) : $mnt_psrc is not mounted but will now mount
    if [ -d $mnt_folder ]; then
        echo $(date) : removing $mnt_folder
        rmdir $mnt_folder
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $mnt_folder
            exit 1
        fi
    fi
    mkdir $mnt_folder
#    echo debug: mount afp:$mnt_src $mnt_folder
    mount_afp afp:$mnt_src $mnt_folder
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $mnt_folder
        exit 1
    fi
    mounted="no"
fi
#
# copy documents
#
echo $(date) : copying documents from $mnt_psrc to $dst_folder
mkdir -p $dst_folder
rsync -av $mnt_folder/ $dst_folder > ~/log/copyfrom_macair_docs.txt
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
#
# copy from macminit
#
rem_mac="rb-macmini.local"
mnt_root="/Users/royboy/Volumes"
mnt_folder=$mnt_root"/macmini_royboy"
dst_folder="/Volumes/MandM/FromMacmini/royboy/Documents"
rem_access="royboy:Portman007"

dst_mounted="no"
#
# backuqp imac docs - set sudo mount name and sudo mount if needed
# for stuff on nas_imac_copy
#
src_folder="/royboy/Documents"
mnt_src="//"$rem_access"@"$rem_mac$src_folder
mnt_psrc="//user:pwd@"$rem_mac$src_folder
#
# see if remote mac is up
#
ping -o $rem_mac &> /dev/null
p_status=$?
if [ $p_status -ne 0 ]; then
  echo $(date) : Warning: $rem_mac is not available
  exit 0
else
  echo $(date) : Copying files from $rem_mac
fi
#
# mount
#
if sudo mount | grep $mnt_src > /dev/null; then
    echo $(date) : $mnt_psrc is mounted
    mounted="yes"
else
    echo $(date) : $mnt_psrc is not mounted but will now mount
    if [ -d $mnt_folder ]; then
        echo $(date) : removing $mnt_folder
        rmdir $mnt_folder
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $mnt_folder
            exit 1
        fi
    fi
    mkdir $mnt_folder
#    echo debug: mount afp:$mnt_src $mnt_folder
    mount_afp afp:$mnt_src $mnt_folder
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $mnt_folder
        exit 1
    fi
    mounted="no"
fi
#
# copy documents
#
echo $(date) : copying documents from $mnt_psrc to $dst_folder
mkdir -p $dst_folder
rsync -av $mnt_folder/ $dst_folder > ~/log/copyfrom_macair_docs.txt
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
