#!/bin/sh
dst_mounted="no"
#
# first get rb-imac's Vault (from NAS/nas_imac_copy/Vaults)
#
dst="nas_imac_copy"
dst_f="Vaults"
m_name="/Volumes/"$dst
if sudo mount | grep $m_name > /dev/null; then
    echo $(date) : $m_name is mounted
    mounted="yes"
else
    echo $(date) : $m_name is not mounted but will now mount
    if [ -d $m_name ]; then
        echo $(date) : removing $m_name
        sudo rmdir $m_name
        r_status=$?
        if [ $r_status -ne 0 ]; then
            echo $(date) : Error: Cannot remove $m_name
            exit 1
        fi
    fi
    sudo mkdir $m_name
    sudo mount_smbfs //Guest@nas/$dst $m_name
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        rmdir $m_name
        exit 1
    fi
    mounted="no"
fi
