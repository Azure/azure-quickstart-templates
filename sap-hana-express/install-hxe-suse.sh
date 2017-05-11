#!/bin/bash

# NOTE: this script assumes to be executed as administrator (sudo install-hxe.sh "url" "server|all" "master-password")

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

#
# Parse arguments into readable bash variables
#
downloadUrl=$1
masterPwd=$2

#
# Prepare the data disks (defaults to /datadisks/diskx)
#
wget --output-document ./vm-disk-utils.sh https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh
chmod +x ./vm-disk-utils.sh
./vm-disk-utils.sh

#
# Pre-Requisites #1 - Java Runtime Environment
#
wget --header "Cookie: oraclelicense=accept-secure-backup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jre-8u131-linux-x64.tar.gz
mkdir /usr/java
chmod -R 777 /usr/java
tar -zxvf jre-8u131-linux-x64.tar.gz -C /usr/java
update-alternatives --install /usr/bin/java java /usr/java/jre1.8.0_131/bin/java 100

#
# Pre-Requisites #2 - Install more pre-requisites with apt
#
zypper -n install libtool
zypper -n install libltdl7

#
# Download and exctract the HXE installation files
# and then start the installation procedure of HXE
# (for HANA 2.0 SPS01, also create an alias for chkconfig)
#

# Download and extract the installation files
wget --output-document="./hxe.tgz" "$downloadUrl"
chmod -R 777 ./hxe.tgz
mkdir /usr/hana
tar -xvzf ./hxe.tgz -C /usr/hana
chmod -R 775 /usr/hana

# Compile a parameters file for input
parametersPrompt="/usr/hana/HANA_EXPRESS_20\n"                # Root directory of installation files
parametersPrompt="${parametersPrompt}$(hostname)\n"           # The hostname needed for HANA
parametersPrompt="${parametersPrompt}HXE\n"                   # System ID of the HANA installation (aligned with tutorials)
parametersPrompt="${parametersPrompt}00\n"                    # Instance number, aligned with the ports opened as per ARM template
parametersPrompt="${parametersPrompt}${masterPwd}\n"          # Master password
parametersPrompt="${parametersPrompt}${masterPwd}\n"          # Master password confirmation
parametersPrompt="${parametersPrompt}Y\n"                     # Confirm the installation

# Start the installation procedure (set the alias for HANA 2.0 SPS01)
printf "$parametersPrompt" | /usr/hana/setup_hxe.sh

# Prompt a final message that all went well
echo ""
echo "------------------------------------"
echo "Successfully installed HANA Express!"
echo "------------------------------------"
exit 0