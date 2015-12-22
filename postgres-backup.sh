#!/bin/bash

########################################################
####### This Script is used to dump the postgres #######
####### database for backup using VMware         #######
####### recommended practices found in KB2074214 #######
########################################################

#VARIABLES
# Location to place backups
backup_dir="/var/tmp/postgres-backup/"

#Date backup occurs
backup_date=$(date +%d-%b-%Y)

#Log file name
backup_log=$backup_dir'vra-'$backup_date.log

#Number of days you want to keep copy of your databases and logs
number_of_days=25

#DB Name
db_name=vra_pg-$backup_date.sql

#Let's reference the time in addition to the date the backup occurred.  We'll capture this in the log
backup_td=$(date +%d-%b-%Y-%r)

#Directory sanity check
if [ ! -d $backup_dir ]; then
        mkdir -p $backup_dir && /bin/chmod o+rwx $backup_dir
        echo Directory created at $backup_td >> $backup_log
        else
        echo Directory was already present >> $backup_log
fi


#Stop vRA Service
/etc/init.d/vcac-server stop

#Backup execution.  PG_ALL is recommended by VMware so that all db's are dumped
echo Commencing backup of vRA postgresql DB to $backup_dir on $backup_td >> $backup_log
su -m -c "/opt/vmware/vpostgres/9.2/bin/pg_dumpall -c -f $backup_dir$db_name" postgres

if [ ! -f $backup_dir$db_name ]; then
        echo $db_name not backed up to $backup_dir on $backup_td >> $backup_log
        else

        echo $db_name successfully backed up to $backup_dir on $backup_td.  Now compressing... >> $backup_log
fi

#Let's compress the backup file here
/usr/bin/bzip2 -z $backup_dir$db_name
echo $db_name successfully compressed and saved as $backup_dir$db_name.bz2 >> $backup_log


#Pruning Step here.  Let's delete any logs and bzip files older than N number of days.  
find $backup_dir -type f -mtime +$number_of_days -delete

#We will start the service here
/etc/init.d/vcac-server start

exit
