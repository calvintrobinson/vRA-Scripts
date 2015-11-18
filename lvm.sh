#!/bin/bash

#This script allows the second drive added to a Linux VM in VRA to have its partition formatted with ext4
#and added to an existing volume group

# Informational only - Arguments which are needed in vRA IF other values should be passed for 
# vg and lv.  We have these values fixed at this time to maintain client standards
# vRA inputs reference - - > $1 = Volume Group Name (vg_root), $2 = Logical Volume Name (lv_data)

drive=sdb
VGNAME=vg_root
LVNAME=lv_data
date=$(date +%m%d%y%H%M%S)

if [ -e /dev/$drive ]
then

#CREATE NEW PARTITION on /DEV/SDB
/bin//bin/echo -e "o\nn\np\n1\n1\n\nt\n8e\nw" | fdisk /dev/$drive

#CREATE NEW PHYSICAL Volume
pvcreate /dev/${drive}1

#EXTEND VG_ROOT VOL GROUP TO ACCOMODATE OUR NEW PARTITION
/sbin/vgextend $VGNAME /dev/${drive}1

#GET # OF FREE EXTENTS
extents=$(/sbin/vgdisplay vg_root|grep "Free  PE" |awk '{print $5}')

#CREATE NEW LOGICAL VOLUME
/sbin/lvcreate --extents $extents -n $LVNAME $VGNAME

#ADD EXT4 FILESYSTEM TO NEW LOGICAL VOLUME
mkfs.ext4 /dev/$VGNAME/$LVNAME

#CREATE THE DIRECTORY WHERE THE NEW LOGICAL VOLUME WILL BE MOUNTED
/bin/mkdir /data

#BACKUP /ETC/FSTAB
cp -p /etc/fstab /etc/fstab.$date

#CREATE FSTAB ENTRY
/bin/echo "/dev/mapper/vg_root-lv_data /data                         ext4    noatime,nodiratime      1 1" >> /etc/fstab

#CLEANUP TASK
rm -rf /var/tmp/lvm.sh

        /bin/echo "/dev/sdb1 formatted and added to vg-root volume group" > /var/tmp/lvm.log
exit 0

else
        /bin//bin/echo "No /dev/sdb drive included during request time" > /var/tmp/lvm.log
exit 0

fi
