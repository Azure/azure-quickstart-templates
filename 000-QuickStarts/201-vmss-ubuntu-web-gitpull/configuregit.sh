#!/bin/bash

# exit on any error
set -e

echo "Welcome to configuressl.sh"
echo "Number of parameters was: " $#

if [ $# -ne 3 ]; then
    echo usage: $0 {git private key} {git reponame} {git user id}      
	exit 1
fi

gitSshPrivateKey=$1
gitRepoName=$2
gitUserId=$3

configure_git_cron()
{
    echo "configurng cron for code updates from git"
    #Configure cronjob to perform git pull every minute
    echo '*/1 * * * * echo $(date) >> /var/log/cronjob.log && cd /var/www/html && git pull >> /var/log/cronjob.log 2>&1' >> /tmp/tmp_gitcron

    echo 'Writing to crontab'
    crontab /tmp/tmp_gitcron
    rm /tmp/tmp_gitcron 
}

setup_sshkey()
{
    local key=${1}
    local host=${2}
    local user=${3}

    key=$(echo $key | base64 --decode);

    local keyfile=~/.ssh/${host}.key

echo "Creating ssh key file.."
cat > "/tmp/tmp_key" << EOF
$key
EOF

cat >> ~/.ssh/config << EOF
Host $host
HostName $host
User $user
IdentityFile $keyfile
EOF

    # Generate the final ssh private key from the keyvault and place in root user context
    cp /tmp/tmp_key $keyfile

    # Add the git domain to known_hosts file for root
    ssh-keyscan $host >> ~/.ssh/known_hosts

    chmod 400 $keyfile

    #remove the tmp key in /tmp/tmp_key
    rm /tmp/tmp_key
}

configure_git()
{
    local key=${1}
    local host=${2}
    local user=${3}
    local repo=${4}

    echo "Configuring git connectivity for $repo"
    echo "Registering git domain: $host"

    if [ ! -z "$key" ]; then
        setup_sshkey $key $host $user

        # remove html dir so we can clone into it
        rm -rf /var/www/html

        echo "Attemtping git clone of dncc repo.."
        git clone git@$host:$user/$repo.git /var/www/html
    else
        echo "no SSH private key. Skipping setup"
    fi 
}

echo "Checking for apache2 already installed"
if dpkg -s apache2 > /dev/null 2>&1; then
     echo "Apache2 installed already - exiting"
     exit
else
     echo "Apache2 not installed - proceeding"
fi

# install needed bits in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately
until apt-get -y update && apt-get -y install apache2 git
do
  echo "Trying again"
  sleep 2
done

# turn off apache until we are done with setup
# Azure LB HTTP/s Probe will fail and not direct traffic to VM 
apachectl stop

configure_git $gitSshPrivateKey github.com $gitUserId $gitRepoName
configure_git_cron

echo "restarting apache"
# all done - turn apache on
apachectl start
echo "Done!"
