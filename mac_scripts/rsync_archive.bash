#!/bin/sh
#
# rsync to backup
#
archive_rsrc=/Volumes/iMacDataSSD/Archive
archive_rdst=/Volumes/BackupArchive/archive
N=no
Y=yes
A_RSRC=${1:-$archive_rsrc}
A_RDST=${2:-$archive_rdst}

A_SRC_FILES="$A_RSRC/youtube_downloads $A_RSRC/youtube_music $A_RSRC/Pictures_Raw $A_RSRC/Pictures"
A_DST=$A_RDST/
for f in $( echo $A_SRC_FILES ); do
    echo $(date) : Copying $f  to $A_DST
    rsync -av --exclude ".*/" --exclude ".DS_Store" $f $A_DST > ~/log/rsync_archive.txt
    echo $(date) : Copying $f to $A_DST complete
done
