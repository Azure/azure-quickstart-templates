#!/bin/bash

echo ""
echo "  Clearing Storage configuration"

storage_config_file='/var/lib/jenkins/com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher.xml'
download_config_file='/var/lib/jenkins/jobs/1. Download Dependencies. Invoked by pipeline/config.xml'
upload_config_file='/var/lib/jenkins/jobs/3. Upload test app. Invoked by pipeline/config.xml'

if [ -f $storage_config_file ]
then
    sudo rm $storage_config_file
fi

if [ -f "$download_config_file" ]
then
    sudo rm "$download_config_file"
fi

if [ -f "$upload_config_file" ]
then
    sudo rm "$upload_config_file"
fi
