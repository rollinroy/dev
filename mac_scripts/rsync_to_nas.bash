#!/bin/sh
#
# rsync to nas on router
#
archive_rsrc=/Volumes/BackupArchive/archive/
ng_folder=ng_ssd
ng_access=//GUEST:@ngshare/$ng_folder
ng_mount=/Volumes/$ng_folder
archive_rdst=$ng_mount/archive
N=no
Y=yes
# check if ng_ssd is src_mounted
if sudo mount | grep $ng_access > /dev/null; then
    echo $(date) : $ng_access is mounted
    mounted="yes"
else
    echo $(date) : $ng_access is not mounted but will now mount
    if [ -d $ng_mount ]; then
        echo $(date) : removing $ng_mount
        sudo rmdir $ng_mount
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $ng_mount
            exit 1
        fi
    fi
    sudo mkdir -p $ng_mount
#    echo debug: mount_afp afp:$mnt_remote $mnt_folder
    sudo mount_smbfs $ng_access $ng_mount
    m_status=$?
    if [ $m_status -ne 0 ]; then
#        rmdir $mnt_folder
        exit 1
    fi
    mounted="no"
fi

echo $(date) : Copying $archive_rsrc  to $archive_rdst
echo "$(date) : sync -av --exclude ".*/" --exclude ".DS_Store" $archive_rsrc $archive_rdst"
sudo rsync -av --exclude ".*/" --exclude ".DS_Store" $archive_rsrc "$archive_rdst" > ~/log/rsync_backuparchive.txt
echo $(date) : Copying $archive_rsrc  to $archive_rdst complete
