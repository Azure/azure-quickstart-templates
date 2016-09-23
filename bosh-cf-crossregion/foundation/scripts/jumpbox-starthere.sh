# 
# Start with this script here
# This script initalizes the SSH agent for your private key file so that you don't need to
# enter SSH Private Key File Passwords over and over again.
#

if [ ! -f ~/.ssh/id_rsa ]
then
    echo "###################################################"
    echo "## No SSH private key file found (~./ssh/id_rsa) ##"
    echo "###################################################"
    exit -10
fi

# Start a Bash with ssh-agent and touch the private key to cache credentials
ssh-agent bash
ssh-add ~/.ssh/id_rsa

# Now start the main script
./jumpbox-install-mariadb-cluster.sh