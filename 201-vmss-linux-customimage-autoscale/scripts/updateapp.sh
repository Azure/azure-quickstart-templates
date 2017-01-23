# Custom Script for Linux (Ubuntu 16)
#!/bin/bash

# exit on any error
set -e

# functions
update_app(){
    curl -o $2 $1
    #you may need to uncompress it
}

restart_service(){
    #something like: systemctl restart mainsite.service
    systemctl restart $3
}

# script start

echo "Welcome to configuressl.sh"
echo "Number of parameters was: " $#

if [ $# -ne 3 ]; then
    echo usage: $0 {sasuri} {destination} {serviceName}
        exit 1
fi

echo "downloading: " $1 "into " $2

update_app $1 $2

echo "restarting service " $3

restart_service $3
