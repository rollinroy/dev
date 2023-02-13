#!/bin/sh
docs_f="Documents"
downloads_f="Downloads"
scripts_f="Scripts"
dev_f="dev"
appinst_f="AppInstallers"
scratch_f="Scratch"
b_docs="/users/royboy/"$docs_f
b_downloads="/users/royboy/"$downloads_f
b_scripts="/users/royboy/"$scripts_f
b_dev="/users/royboy/"$dev_f
b_appinst="/"$appinst_f
b_scratch="/"$scratch_f
dst="ng_mac"
dst_f="ng_macmini"
dst_mounted="no"
#
# backup - set mount name and mount if needed for stuff on MacData
#
m_name="/Volumes/"$dst
if mount | grep $m_name > /dev/null; then
    echo $(date) : $m_name is mounted
    mounted="yes"
else
    echo $(date) : $m_name is not mounted but will now mount
    if [ -d $m_name ]; then
        echo $(date) : removing $m_name
        rmdir $m_name
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $m_name
            exit 1
        fi
    fi
    mkdir $m_name
    mount_smbfs //Guest@ngshare/$dst $m_name
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $m_name
        exit 1
    fi
    mounted="no"
fi
#
# copy documents
#
echo $(date) : copying documents
rsync -av $b_docs $m_name"/"$dst_f > ~/log/backup_doc_files.txt

echo $(date) : copying to $m_name complete
if [ "$mounted" == "no" ]; then
   echo $(date) : Unmounting $m_name
   umount $m_name
else
   echo $(date) : Keeping $m_name mounted
fi
