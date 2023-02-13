#!/bin/sh
docs_f="Documents"
vaults_f="Vaults"
b_vaults="/Volumes/MacData/"$vaults_f
b_docs="/users/royboy/"$docs_f
dst="imac_backup"
mounted="no"
#
# set mount name and mount if needed
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
    mount_smbfs //Guest@NAS/$dst $m_name
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $m_name
        exit 1
    fi
fi
#
# copy documents
#
echo $(date) : copying documents
#cp -Rf $b_docs $m_name
rsync -av $b_docs $m_name > backup_doc_files.txt
#
# copy vaults
#
echo $(date) : copying vaults
#cp -Rf $b_vaults $m_name
rsync -av $b_vaults $m_name > backup_vault_files.txt
echo $(date) : All copying complete
if [ "$mounted" == "no" ]; then
   echo $(date) : Unmounting $m_name
   umount $m_name
else
   echo $(date) : Keeping $m_name mounted
fi
