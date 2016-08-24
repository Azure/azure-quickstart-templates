#!/bin/sh
storage_config_file='/var/lib/jenkins/com.microsoftopentechnologies.windowsazurestorage.WAStoragePublisher.xml'
download_config_file='/var/lib/jenkins/jobs/AzureStorageDownloadJob/config.xml'
upload_config_file='/var/lib/jenkins/jobs/AzureStorageUploadJob/config.xml'

if [ -f $storage_config_file ]
then
    sudo rm $storage_config_file
fi

if [ -f $download_config_file ]
then
    sudo rm $download_config_file
fi

if [ -f $upload_config_file ]
then
    sudo rm $upload_config_file
fi
