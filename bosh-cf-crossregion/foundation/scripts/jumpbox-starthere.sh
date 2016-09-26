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

# Get all MariaDB related scripts from GitHub
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/jumpbox-install-mariadb-cluster.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/cluster.cnf
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/dbnodes-mariadb-installation.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/dbnodes-mariadb-setup.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/sql-cluster-check.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/sql-remote-clusteradmin.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/dbnodes-prep-datadrives.sh

# Get all NFS related scripts from GitHub
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/jumpbox-install-nfs-cluster.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/nfsnodes-prep-datadrives.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/nfsnodes-drbd-setup.sh
wget https://raw.githubusercontent.com/mszcool/azure-quickstart-templates/master/bosh-cf-crossregion/foundation/scripts/nfsnodes.drbd.d.r0.res

# Enable all scripts for execution
chmod +x *.sh

# Start a Bash with ssh-agent and touch the private key to cache credentials
# ssh-agent bash
# ssh-add ~/.ssh/id_rsa

# Now start the main script
echo "#################"
echo "## Next steps: ##"
echo "#################"
echo -e "- Enable ssh-agent for private key caching:\tssh-agent bash"
echo -e "- Cache SSH Private Key Passphrase:\t\tssh-add ~/.ssh/id_rsa"
echo -e "- Install Galera Cluster:\t\t\t./jumpbox-install-mariadb-cluster.sh"
echo -e "- Install Cross-Region NFS cluster:\t\t./jumpbox-install-nfs-cluster.sh"