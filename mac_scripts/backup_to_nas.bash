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
        sudo rmdir $m_name
        exit 1
    fi
    mounted="no"
fi
#
# copy Vault to local (~/documents)
#
echo $(date) : copying vaults from $m_name"/"$dst_f to ~/Documents
sudo rsync -av $m_name"/"$dst_f ~/Documents > ~/log/get_vaults.txt
echo $(date) : vaults copying complete
#
# init variables for backup
#
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
#
# backup - set mount name and mount if needed for stuff on MacData
#
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
    sudo mount_smbfs //Guest@ngshare/$dst $m_name
    m_status=$?
    if [ $m_status -ne 0 ]; then
        echo $(date) : Error: mount failed
        sudo rmdir $m_name
        exit 1
    fi
    mounted="no"
fi
#
# copy documents
#
echo $(date) : copying documents
sudo rsync -av $b_docs $m_name"/"$dst_f > ~/log/backup_doc_files.txt
#
# copy Downloads
#
echo $(date) : copying downloads
sudo rsync -av $b_downloads $m_name"/"$dst_f > ~/log/backup_downloads_files.txt
#
# copy Scripts
#
echo $(date) : copying scripts
sudo rsync -av $b_scripts $m_name"/"$dst_f > ~/log/backup_scripts_files.txt
#
# copy dev
#
echo $(date) : copying dev
sudo rsync -av $b_dev $m_name"/"$dst_f > ~/log/backup_dev_files.txt
#
# copy appinstallers
#
echo $(date) : copying appinstallers
sudo rsync -av $b_appinst $m_name"/"$dst_f > ~/log/backup_appinst_files.txt
#
# copy scratch
#
echo $(date) : copying scratch
sudo rsync -av $b_scratch $m_name"/"$dst_f > ~/log/backup_scratch_files.txt

echo $(date) : copying to $m_name"/"$dst_f complete
if [ "$mounted" == "no" ]; then
   echo $(date) : Unmounting $m_name
   sudo umount $m_name
else
   echo $(date) : Keeping $m_name mounted
fi
