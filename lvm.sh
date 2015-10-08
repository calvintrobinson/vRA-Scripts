#!/bin/bash
#This file let's you configure LVM for /dev/sdb1 in vRA on Linux Machines


# $1 = Volume Group Name (vg_root), $2 = Logical Volume Name (lv_data), $3 = Partition Size of LVM
drive=sdb
VGNAME=vg_root
LVNAME=lv_data
date=$(date +%m%d%y%H%M%S)


#CREATE NEW PARTITION on /DEV/SDB
echo -e "o\nn\np\n1\n1\n\nt\n8e\nw" | fdisk /dev/$drive

#CREATE NEW PHYSICAL Volume
pvcreate /dev/${drive}1

#EXTEND VG_ROOT VOL GROUP TO ACCOMODATE OUR NEW PARTITION
/sbin/vgextend $VGNAME /dev/${drive}1

#get the number of free extents
extents=$(/sbin/vgdisplay vg_root|grep "Free  PE" |awk '{print $5}')

#CREATE NEW LOGICAL VOLUME
/sbin/lvcreate --extents $extents -n $LVNAME $VGNAME


mkfs.ext4 /dev/$VGNAME/$LVNAME

/bin/mkdir /data

cp -p /etc/fstab /etc/fstab.$date
 
echo "/dev/mapper/vg_root-lv_data /data                   	ext4	noatime,nodiratime    	1 1" >> /etc/fstab
 
#mount /data
