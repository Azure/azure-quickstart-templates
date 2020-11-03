#!/bin/bash
# Custom Script for Linux (Ubuntu 16)

# exit on any error
set -e

# functions
update_app(){
    echo "creating folder " $2 "/temp"
    mkdir $2
    mkdir $2/temp

    if [ ${1:0:4} == "http" ]; then
        cd $2/temp
        echo "downloading" $1
        wget --content-disposition $1
    else
        cp $1 $2/temp/
        cd $2/temp
    fi
    #uncompress it
    tar -xzvf *.tar.gz -C ../
    cd -
    rm -r $2/temp
}

restart_service(){
    # something like: systemctl restart mainsite.service
    # this sample originally expected a specific custom image that's no longer available... so the service in question may not exist.
    # systemctl restart $1
    pwd
}

# script start

echo "Welcome to updateapp.sh"
echo "Number of parameters was: " $#

if [ $# -ne 3 ]; then
    echo usage: $0 {sasuri} {destination} {serviceName}
        exit 1
fi

echo "downloading: " $1 "into " $2

update_app $1 $2

echo "restarting service " $3

restart_service $3
