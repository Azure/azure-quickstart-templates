

#!/bin/bash
# $1 = Azure storage account name
# $2 = Azure storage account key
# $3 = Azure file share name
# $4 = mountpoint path
# $5 - username

# For more details refer to https://azure.microsoft.com/en-us/documentation/articles/storage-how-to-use-files-linux/

# update package lists
apt-get -y update

# install cifs-utils and mount file share
apt-get install cifs-utils
mkdir $4
mount -t cifs //$1.file.core.windows.net/$3 $4 -o vers=3.0,username=$1,password=$2,dir_mode=0755,file_mode=0664

# create a symlink from /mountpath/xxx to ~username/xxx
linkpoint=`echo $4 | sed 's/.*\///'`
eval ln -s $4 ~$5/$linkpoint

# create marker files for testing
echo "hello from $HOSTNAME" > $4/$HOSTNAME.txt



