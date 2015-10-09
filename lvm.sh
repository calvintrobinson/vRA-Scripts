#!/bin/bash

#This script allows the second drive added to a Linux VM in VRA to have its partition formatted with ext4
#and added to an existing volume group

# $1 = Volume Group Name (vg_root), $2 = Logical Volume Name (lv_data), $3 = Partition Size of LVM
drive=sdb
VGNAME=vg_root
LVNAME=lv_data
date=$(date +%m%d%y%H%M%S)

if [ -e /dev/$drive ]
then

#CREATE NEW PARTITION on /DEV/SDB
echo -e "o\nn\np\n1\n1\n\nt\n8e\nw" | fdisk /dev/$drive

#CREATE NEW PHYSICAL Volume
pvcreate /dev/${drive}1

#EXTEND VG_ROOT VOL GROUP TO ACCOMODATE OUR NEW PARTITION
/sbin/vgextend $VGNAME /dev/${drive}1

#GET # OF FREE EXTENTS
extents=$(/sbin/vgdisplay vg_root|grep "Free  PE" |awk '{print $5}')

#CREATE NEW LOGICAL VOLUME
/sbin/lvcreate --extents $extents -n $LVNAME $VGNAME

#FORMAT THE NEW LOGICAL VOLUME
mkfs.ext4 /dev/$VGNAME/$LVNAME

#CREATE THE FOLDER WHERE THE NEW LOGICAL VOLUME WILL BE MOUNTED
/bin/mkdir /data

#BACKUP /ETC/FSTAB
cp -p /etc/fstab /etc/fstab.$date

#CREATE FSTAB ENTRY
echo "/dev/mapper/vg_root-lv_data /data                         ext4    noatime,nodiratime      1 1" >> /etc/fstab

#mount /data
rm -rf /var/tmp/lvm.sh

        echo "/dev/sdb1 formatted and added to vg-root volume group" > /var/tmp/lvm.log
exit 0

else
        echo "No /dev/sdb drive selected during request time" > /var/tmp/lvm.log
fi
