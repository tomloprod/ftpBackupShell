#!/bin/sh

send_to_ftp(){
  ftp -n -i $SERVER $PORT <<EOF
  user $USERNAME $PASSWORD
  binary
  put $1 $REMOTEDIR/$1
  quit
EOF
}

########################
#    CONFIGURATION     #
########################

# FTP Login Data
USERNAME="myFTPUserName"
PASSWORD="myPassword"
SERVER="192.168.0.250"
PORT="21"

# Array of directories where thing to backup is located
declare -a DIR=("directoryToBackup1/subfolder" "directoryToBackup2")

#Remote directory where the backup will be placed
REMOTEDIR="./my_destination_folder"

# Array of filenames of backup file to be transfered (DON'T WRITE EXTENSION)
declare -a FILE=("nameOfTARFile1" "nameOfTARFile2")

#Transfer type
#1=FTP
#2=SFTP
TYPE=1

########################
#  END  CONFIGURATION  #
########################

d=$(date --iso)

for i in "${!DIR[@]}";
do
   echo "BACKUP DE ${DIR[$i]}"
   CURRENT_FILE=${FILE[$i]}"_"$d".tar.gz"
   tar -czvf ./$CURRENT_FILE ${DIR[$i]}
   echo "*** TAR COMPLETE: $REMOTEDIR/$CURRENT_FILE"
   echo "*** FTP: $REMOTEDIR/$CURRENT_FILE..."
   if [ $TYPE -eq 1 ]
      then
         send_to_ftp "$CURRENT_FILE"
      elif [ $TYPE -eq 2 ]
      then
         rsync --rsh="sshpass -p $PASSWORD ssh -p $PORT -o StrictHostKeyChecking=no -l $USERNAME" $CURRENT_FILE $SERVER:$REMOTEDIR
      else
         echo 'Please select a valid type'
   fi
   rm -f $CURRENT_FILE
done

echo 'Remote Backup Complete'
#END
