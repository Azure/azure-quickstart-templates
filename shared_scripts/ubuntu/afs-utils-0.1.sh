#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Script Name: afs-utils.sh
# Author: Hans Krijger (github:hglkrijger)
# Version: 0.1
# Last Modified By: Hans Krijger
# Description:
#  This script provides basic functionality for creating and mounting an Azure
#  File Service share for use by Elasticsearch.
# Note:
# This script has only been tested on Ubuntu 14.04 LTS and must be root

help()
{
    echo "Usage: $(basename $0) -a storage_account -k access_key [-h] [-c] [-p] [-s share_name] [-b base_directory]"
    echo "Options:"
    echo "  -a    storage account which hosts the shares (required)"
    echo "  -k    access key for the storage account (required)"
    echo "  -h    this help message"
    echo "  -c    create and mount afs share"
    echo "  -p    persist the mount (default: non persistent)"
    echo "  -s    name of the share (default: esdata00)"
    echo "  -b    base directory for mount points (default: /sharedfs)"
}

error()
{
    echo "$1" >&2
    exit 3
}

log()
{
    echo "$1"
}

# issue_signed_request
#   <verb> - GET/PUT/POST
#   <url> - the resource uri to actually post
#   <canonical resource> - the canonicalized resource uri
# see https://msdn.microsoft.com/en-us/library/azure/dd179428.aspx for details
issue_signed_request() {
    request_method="$1"
    request_url="$2"
    canonicalized_resource="/${STORAGE_ACCOUNT}/$3"

    request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
    storage_service_version="2015-04-05"
    authorization="SharedKey"
    file_store_url="file.core.windows.net"
    full_url="https://${STORAGE_ACCOUNT}.${file_store_url}/${request_url}"

    x_ms_date_h="x-ms-date:$request_date"
    x_ms_version_h="x-ms-version:$storage_service_version"
    canonicalized_headers="${x_ms_date_h}\n${x_ms_version_h}\n"
    content_length_header="Content-Length:0"

    string_to_sign="${request_method}\n\n\n\n\n\n\n\n\n\n\n\n${canonicalized_headers}${canonicalized_resource}"
    decoded_hex_key="$(echo -n ${ACCESS_KEY} | base64 -d -w0 | xxd -p -c256)"
    signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary |  base64 -w0)
    authorization_header="Authorization: $authorization ${STORAGE_ACCOUNT}:$signature"

    curl -sw "/status/%{http_code}/\n" \
        -X $request_method \
        -H "$x_ms_date_h" \
        -H "$x_ms_version_h" \
        -H "$authorization_header" \
        -H "$content_length_header" \
        $full_url
}

validate() {
    if [ ! "$1" ];
    then
        error "response was null"
    fi

    if [[ $(echo ${1} | grep -o "/status/2") || $(echo ${1} | grep -o "/status/409") ]];
    then
        # response is valid or share already exists, ignore
        return
    else
        # other or unknown status
        if [ $(echo ${1} | grep -o "/status/") ];
        then
            error "response was not valid: ${1}"
        else
            error "no response code found: ${1}"
        fi
    fi
}

list_shares() {
    response="$(issue_signed_request GET ?comp=list "\ncomp:list")"
    echo ${response}
}

create_share() {
    share_name="$1"
    log "creating share $share_name"

    # test whether share exists already
    response=$(list_shares)
    validate "$response"
    exists=$(echo ${response} | grep -c "<Share><Name>${share_name}</Name>")

    if [ ${exists} -eq 0 ];
    then
        # create share
        response=$(issue_signed_request "PUT" "${share_name}?restype=share" "${share_name}\nrestype:share")
        validate "$response"
    fi
}

mount_share() {
    share_name="$1"
    mount_location="$2"
    persist="$3"
    creds_file="/etc/cifs.${share_name}"
    mount_options="vers=3.0,dir_mode=0777,file_mode=0777,credentials=${creds_file}"
    mount_share="//${STORAGE_ACCOUNT}.file.core.windows.net/${SHARE_NAME}"

    log "creating credentials at ${creds_file}"
    echo "username=${STORAGE_ACCOUNT}" >> ${creds_file}
    echo "password=${ACCESS_KEY}" >> ${creds_file}
    chmod 600 ${creds_file}

    log "mounting share $share_name at $mount_location"

    if [ $(cat /etc/mtab | grep -o "${mount_location}") ];
    then
        error "location ${mount_location} is already mounted"
    fi

    [ -d "${mount_location}" ] || mkdir -p "${mount_location}"
    mount -t cifs ${mount_share} ${mount_location} -o ${mount_options}

    if [ ! $(cat /etc/mtab | grep -o "${mount_location}") ];
    then
        error "mount failed"
    fi

    if [ ${persist} ];
    then
        # create a backup of fstab
        cp /etc/fstab /etc/fstab_backup

        # update /etc/fstab
        echo ${mount_share} ${mount_location} cifs ${mount_options} >> /etc/fstab

        # test that mount works
        umount ${mount_location}
        mount ${mount_location}

        if [ ! $(cat /etc/mtab | grep -o "${mount_location}") ];
        then
            # revert changes
            cp /etc/fstab_backup /etc/fstab
            error "/etc/fstab was not configured correctly, changes reverted"
        fi
    fi
}

#######################################

if [ "${UID}" -ne 0 ];
then
    error "You must be root to run this script."
fi

STORAGE_ACCOUNT=""
ACCESS_KEY=""
SHARE_NAME="esdata00"
BASE_DIRECTORY="/sharedfs"

while getopts :b:a:k:s:pch optname; do
  log "Option $optname set"
  case ${optname} in
    b) BASE_DIRECTORY=${OPTARG};;
    a) STORAGE_ACCOUNT=${OPTARG};;
    k) ACCESS_KEY=${OPTARG};;
    s) SHARE_NAME=${OPTARG};;
    p) PERSIST=1;;
    c) CREATE_MOUNT=1;;
    h) help; exit 1;;
   \?) help; error "Option -${OPTARG} not supported.";;
    :) help; error "Option -${OPTARG} requires an argument.";;
  esac
done

if [ ! ${STORAGE_ACCOUNT} ];
then
    help
    error "Storage account is required."
fi

if [ ! ${ACCESS_KEY} ];
then
    help
    error "Access key is required."
fi

### create and mount a share in the specified storage account
if [ ${CREATE_MOUNT} ];
then
    create_share "$SHARE_NAME"
    mount_share "$SHARE_NAME" "${BASE_DIRECTORY}/${SHARE_NAME}" $PERSIST
fi
