#!/bin/sh
docs_f="Documents"
downloads_f="Downloads"
scripts_f="Scripts"
pics_f="Pictures"
scratch_f="Scratch"

b_docs="/users/royboy/"$docs_f
b_downloads="/users/royboy/"$downloads_f
b_scripts="/users/royboy/"$scripts_f
b_pics="/users/royboy/"$pics_f
b_scratch="/users/royboy/"$scratch_f

dst_mounted="no"
#
# first get rb-imac's Vault (from NAS/nas_imac_copy/Vaults)
#
dst="nas_imac_copy"
dst_f="Vaults"
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
    mount_smbfs //Guest@nas/$dst $m_name
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $m_name
        exit 1
    fi
    mounted="no"
fi
#
# copy Vault to local (~/documents)
#
echo $(date) : copying vault from $m_name"/"$dst_f to ~/Documents
rsync -av $m_name"/"$dst_f ~/Documents > ~/log/get_vaults.txt
echo $(date) : vaults copying complete
