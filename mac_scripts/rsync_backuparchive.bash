#!/bin/sh
#
# rsync to backup
#
#archive_rsrc=/Volumes/iMacDataSSD/Archive
archive_rsrc=/Volumes/BackupArchive/archive/
#archive_rdst=/Volumes/Archive
#archive_rdst=/Volumes/BackupArchive/archive
archive_rdst="/Volumes/BackupArchive 1/archive"
#archive_rsrc=/Volumes/Archive/
N=no
Y=yes
echo $(date) : Copying $archive_rsrc  to $archive_rdst
sudo rsync -av --exclude ".*/" --exclude ".DS_Store" $archive_rsrc "$archive_rdst" > ~/log/rsync_backuparchive.txt
echo $(date) : Copying $archive_rsrc  to $archive_rdst complete
