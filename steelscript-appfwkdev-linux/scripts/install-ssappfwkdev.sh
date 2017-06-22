#!/bin/bash
#
#.SYNOPSIS
#    Steelscript Application Framework setup for developper (ssappfwkdev)
#.DESCRIPTION
#    @Version: 2.0.0.10
#    @Author: Gwen Blum
#    @Date: 20160520 
#    @Changelog:
#       20170622    Add progressd check
#       20170609    Merge ubuntu and centos scripts, add password param
#       20170602    add temporary patch for appfwk explicit app_label issue
#
#    It installs SteelScript Application Framework on a fresh linux VM
#    Steelscript Application Framework reference: https://support.riverbed.com/apis/steelscript/appfwk/toc.html
#    Tested on CentOS 7.0.1406,7.2,7.3 and Ubuntu 17.04
#.EXAMPLE
#    ./install-ssappfwkdev.sh 
#
#   # Then the appfwk server can be started manually from the project dir (/appfwk_project)
#   cd /appfwk_project ; sudo python "/appfwk_project/manage.py" runserver 0.0.0.0:8000
#
#>

############################################################################################
#0 Script initialization

### Static
steelscriptpathCentos=/usr/lib/python2.7/site-packages/steelscript
steelscriptpathUbuntu=/usr/local/lib/python2.7/dist-packages/steelscript
appfwkServerPort=8000
projectpath=/appfwk_project

### Check linuxos and set variables
if [ -e /etc/redhat-release ]; then
    # code for CentOS
    linuxos="redhat-release"
    steelscriptpath=$steelscriptpathCentos
elif [ -e /etc/lsb-release ]; then
    # code for Ubuntu
    linuxos="lsb-release"
    steelscriptpath=$steelscriptpathUbuntu
else
    echo "$(date +%H:%M:%S) ERROR:  Cannot identify a valid Linux distribution (CentOS or Ubuntu)" 1>&2
    exit 11
fi

############################################################################################
#1 Install prerequisites (python, pip, devel, ...)
echo "$(date +%H:%M:%S) 1/3 INSTALL PREREQUISITES"

case $linuxos in
"redhat-release") 
    echo "Centos prerequisites..."
    sudo yum clean all
    sudo yum -y groupinstall "Development tools"
    sudo yum -y install python-devel

    #### pip - https://pip.pypa.io/en/stable/
    sudo wget "https://bootstrap.pypa.io/get-pip.py" -O /tmp/get-pip.py
    sudo python /tmp/get-pip.py
;;
"lsb-release")
    echo "Ubuntu prerequisites..."
    sudo apt-get -qq update
    sudo apt-get -qq install python-pip
;;
*)
    echo "$(date +%H:%M:%S) ERROR:  prerequisites installation unhandled for this Linux distribution" 1>&2
    exit 12
;;
esac

############################################################################################
#2 Install SteelScript (steelscript, app framework, progressd) and configure (appfwk project)
echo "$(date +%H:%M:%S) 2/3 INSTALL STEELSCRIPT AND CONFIGURE"

#### Install Steelscript and Steelscript App Framework https://github.com/riverbed/steelscript-appfwk
#### Remark: steelscript can be installed with pip (or from sources, wget https://support.riverbed.com/apis/steelscript/_downloads/steel_bootstrap.py ; sudo python steel_bootstrap.py install)
sudo pip install steelscript
sudo steel install
sudo steel install --appfwk

#### If required, apply a patch to fix explicit app_label issue in App Framework (found on Appfwk1.4, a pull request has been submitted https://github.com/riverbed/steelscript-appfwk/blob/master/steelscript/appfwk/apps/db/models.py)
echo "Checking if explicit app_label patch is required..."
filetopatch=$steelscriptpath/appfwk/apps/db/models.py
if (! grep app_label $filetopatch); then
echo "Patching Steelscript App Framework: 20170602 - fix explicit app_label issue"
echo "---------------------------------------------------------------------------"
echo "File to patch: $filetopatch"
cat $filetopatch
echo "---------------------------------------------------------------------------"
patchfile=/tmp/appfw-models.py.patch
cat > $patchfile << EOL
12a13,14
>     class Meta:
>         app_label = 'steelscript.appfwk'
EOL
echo "Patch: $patchfile"
cat $patchfile
echo "---------------------------------------------------------------------------"
sudo patch $filetopatch -i $patchfile
echo "File patched: $filetopatch"
cat $filetopatch
echo "---------------------------------------------------------------------------"
fi

#### Create Steelscript App Framework project, ref: https://github.com/riverbed/steelscript-appfwk
echo "Creating Steelscript App Framework project..."
sudo steel appfwk mkproject -d $projectpath
cd $projectpath ; sudo steel appfwk init

### Install progressd daemon https://github.com/riverbed/steelscript-vm-config/blob/master/provisioning/roles/appfwk_webserver/templates/etc.init.d.progressd.distrib.j2
echo "Installing progressd daemon..."
daemonfile=/etc/init.d/progressd
sudo wget "https://github.com/riverbed/steelscript-vm-config/raw/master/provisioning/roles/appfwk_webserver/templates/etc.init.d.progressd.distrib.j2" -O $daemonfile
sudo chmod +xxx /etc/init.d/progressd

### Configure progressd Daemon 
#    Set following variables in /etc/init.d/progressd
#     dir="{{ virtualenv_apache }}/lib/python2.7/site-packages/steelscript/appfwk/progressd"
#     user="{{ project_owner_apache }}"
#     cmd="{{ virtualenv_apache }}/bin/python progressd.py --path {{ project_root_apache }} --port {{ apache_progressd_port }}"
#
#    Values for Centos:
#     dir="/usr/lib/python2.7/site-packages/steelscript/appfwk/progressd"
#     cmd="/usr/bin/python progressd.py --path /appfwk_project --port 5000"  
#     user="root"
#    Values for Ubuntu:
#     dir="/usr/local/lib/python2.7/dist-packages/steelscript/appfwk/progressd"
echo "Configuring progressd..."

daemonfile=/etc/init.d/progressd
progressddir=$steelscriptpath/appfwk/progressd
progressdport=5000
progressduser="root"

sudo sed -i 's|dir=.*|dir=\"'$progressddir'\"|' $daemonfile
sudo sed -i 's|{{ virtualenv_apache }}|/usr|' $daemonfile
sudo sed -i 's|{{ project_owner_apache }}|'$progressduser'|' $daemonfile
sudo sed -i 's|{{ project_root_apache }}|'$projectpath'|' $daemonfile
sudo sed -i 's|{{ apache_progressd_port }}|'$progressdport'|' $daemonfile

### Remove Django hosts check security
#   ALLOWED_HOSTS=['*']
settingsfile=$projectpath/local_settings.py
if (! grep "ALLOWED_HOSTS=" $settingsfile); then
echo "ALLOWED_HOSTS=['*']" | sudo tee -a $settingsfile
fi

### Set progressd service startup
case $linuxos in
"redhat-release") 
    sudo chkconfig --add progressd
;;
"lsb-release")
    sudo update-rc.d progressd defaults
;;
*)
    echo "$(date +%H:%M:%S) WARNING:  progressd startup unhandled for this Linux distribution" 1>&2
;;
esac

### Start progressd 
sudo service progressd restart

############################################################################################
#3 Summary
echo "$(date +%H:%M:%S) 3/3 INSTALLATION SUMMARY"
echo "---------------------------------------------------------------------------"
echo "--------- Show steel about"
sudo steel about
echo "---------------------------------------------------------------------------"
echo "--------- Show $daemonfile"
head /etc/init.d/progressd
echo "---------------------------------------------------------------------------"
echo "--------- Checking progressd status..."
sudo /etc/init.d/progressd status
#sudo service progressd status
echo "---------------------------------------------------------------------------"
echo "--------- Show $settingsfile"
tail $settingsfile
echo "---------------------------------------------------------------------------"
echo -e "--------- To start the SteelScript Application Framework project: \n    cd $projectpath ; sudo python \"$projectpath/manage.py\" runserver 0.0.0.0:$appfwkServerPort"
echo "---------------------------------------------------------------------------"
#######################

### Start Steelscript Application Framework server
cd $projectpath ; sudo python "/appfwk_project/manage.py" runserver 0.0.0.0:$appfwkServerPort &

sleep 15

### Final check
curl http://127.0.0.1:5000
if [ $? -ne 0 ]; then
echo "$(date +%H:%M:%S) ERROR:  progressd not running" 1>&2
exit 2
fi

curl http://127.0.0.1:$appfwkServerPort
if [ $? -ne 0 ]; then
echo "$(date +%H:%M:%S) ERROR:  appfwk not running" 1>&2
exit 3
fi

exit 0
