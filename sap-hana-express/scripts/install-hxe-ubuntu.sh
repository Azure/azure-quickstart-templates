# NOTE: this script assumes to be executed as administrator (sudo install-hxe.sh "url" "server|all" "master-password")

#
# Parse arguments into readable bash variables
#
downloadUrl=$1
installComponents=$2
masterPwd=$3

#
# First get the OS to the laste patch grade
#
apt-get -y update
apt-get -y upgrade

#
# Pre-Requisites #1 - Java Runtime Environment
#
wget --header "Cookie: oraclelicense=accept-secure-backup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jre-8u131-linux-x64.tar.gz
mkdir /usr/java
chmod 777 /usr/java
cp ./jre-8u131-linux-x64.tar.gz /usr/java/jre-8u131-linux-x64.tar.gz
cd /usr/java
tar -zxvf jre-8u131-linux-x64.tar.gz
cd ~
update-alternatives --install /usr/bin/java java /usr/java/jre1.8.0_131/bin/java 100

#
# Pre-Requisites #2 - Install more pre-requisites with apt
#
apt-get install -y openssl
apt-get install -y libpam-cracklib
apt-get install -y libltdl7
apt-get install -y libaio1
apt-get install -y unzip
apt-get install -y curl
apt-get install -y sysv-rc-conf

#
# Download and exctract the HXE installation files
# and then start the installation procedure of HXE
# (for HANA 2.0 SPS01, also create an alias for chkconfig)
#

# Download and extract the installation files
wget --output-document=hxe.tgz $downloadUrl
chmod -R 777 hxe.tgz
tar -xvzf hxe.tgz

# Compile a parameters file for input
parametersPrompt="/home/marioszp/HANA_EXPRESS_20\n"                    # Root directory of installation files
parametersPrompt="${parametersPrompt}$(hostname)\n"           # The hostname needed for HANA
parametersPrompt="${parametersPrompt}HXE\n"                   # System ID of the HANA installation (aligned with tutorials)
parametersPrompt="${parametersPrompt}00\n"                    # Instance number, aligned with the ports opened as per ARM template
parametersPrompt="${parametersPrompt}${masterPwd}\n"          # Master password
parametersPrompt="${parametersPrompt}${masterPwd}\n"          # Master password confirmation
parametersPrompt="${parametersPrompt}Y\n"                     # Confirm the installation

# Start the installation procedure (set the alias for HANA 2.0 SPS01)
alias chkconfig='sysv-rc-conf'
ln -s /usr/sbin/sysv-rc-conf /usr/bin/chkconfig
printf "$parametersPrompt" | /home/marioszp/setup_hxe.sh