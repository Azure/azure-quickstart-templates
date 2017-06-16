#!/usr/bin/env bash

#
# Script for installing Ansible and the edX configuration repostory
# onto a host to enable running ansible to complete configuration.
# This script can be used by Docker, Packer or any other system
# for building images that requires having ansible available.
#
# Can be run as follows:
#
# UPGRADE_OS=true CONFIGURATION_VERSION="master" \
# bash <(curl -s https://raw.githubusercontent.com/edx/configuration/master/util/install/ansible-bootstrap.sh)

set -xe


if [[ -z "${UPGRADE_OS}" ]]; then
  UPGRADE_OS=false
fi

#
# Bootstrapping constants
#
VIRTUAL_ENV_VERSION="15.0.2"
PIP_VERSION="8.1.2"
SETUPTOOLS_VERSION="24.0.3"
VIRTUAL_ENV="/badgr/env"
VIRTUAL_ENV_ACTIVATE="${VIRTUAL_ENV}/bin/activate"
BADGR_ROOT_DIR=/badgr
BADGR_REPO=https://github.com/satyarapelly/badgr-server.git
BADGR_APP_DIR=/badgr/code
BADGR_ADMIN_USER=""
BADGR_ADMIN_USER_PWD=""

if [[ $(id -u) -ne 0 ]] ;then
    echo "Please run as root";
    exit 1;
fi

if grep -q 'Precise Pangolin' /etc/os-release
then
    SHORT_DIST="precise"
elif grep -q 'Trusty Tahr' /etc/os-release
then
    SHORT_DIST="trusty"
elif grep -q 'Xenial Xerus' /etc/os-release
then
    SHORT_DIST="xenial"
else
    cat << EOF

    This script is only known to work on Ubuntu Precise, Trusty and Xenial,
    exiting.  If you are interested in helping make installation possible
    on other platforms, let us know.

EOF
   exit 1;
fi

parse_args()
{
    while [[ "$#" -gt 0 ]]
        do

        arg_value="${2}"
        shift_once=0

        if [[ "${arg_value}" =~ "--" ]]; 
        then
            arg_value=""
            shift_once=1
        fi

         # Log input parameters to facilitate troubleshooting
        echo "Option '${1}' set with value '"${arg_value}"'"

        case "$1" in
            -u| --admin-user) # OS Admin User Name
                BADGR_ADMIN_USER="${arg_value}"
                ;;
			-p| --admin-user-password) # OS Admin User Name
                BADGR_ADMIN_USER_PWD="${arg_value}"
                ;;	
			*) # unknown option
                echo "Option '${BOLD}$1${NORM} ${arg_value}' not allowed."
                help
                exit 2
                ;;
        esac
        
        shift # past argument

        if [ $shift_once -eq 0 ]; 
        then
            shift # past argument or value
        fi

    done
}

parse_args $@ # pass existing command line arguments

# Upgrade the OS
apt-get update -y
apt-key update -y


if [ "${UPGRADE_OS}" = true ]; then
    echo "Upgrading the OS..."
    apt-get upgrade -y
fi

# Required for add-apt-repository
apt-get install -y software-properties-common python-software-properties

# Add git PPA
add-apt-repository -y ppa:git-core/ppa

# Install python 2.7 latest, git and other common requirements
# NOTE: This will install the latest version of python 2.7 and
# which may differ from what is pinned in virtualenvironments
apt-get update -y

apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2 python-dev build-essential sudo git-core libmysqlclient-dev libffi-dev libssl-dev gcc npm ruby gunicorn supervisor


# Workaround for a 16.04 bug, need to upgrade to latest and then
# potentially downgrade to the preferred version.
if [[ "xenial" = "${SHORT_DIST}" ]]; then
    #apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2
    pip install --upgrade pip
    pip install --upgrade pip=="${PIP_VERSION}"
    #apt-get install -y build-essential sudo git-core libmysqlclient-dev
else
    #apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2 build-essential sudo git-core libmysqlclient-dev
    pip install --upgrade pip=="${PIP_VERSION}"
fi

# pip moves to /usr/local/bin when upgraded
PATH=/usr/local/bin:${PATH}
pip install setuptools=="${SETUPTOOLS_VERSION}"
pip install virtualenv=="${VIRTUAL_ENV_VERSION}"

gem install sass

sudo su
cd /
mkdir $BADGR_ROOT_DIR
cd $BADGR_ROOT_DIR
virtualenv "${VIRTUAL_ENV}"
source $VIRTUAL_ENV_ACTIVATE

git clone $BADGR_REPO $BADGR_APP_DIR
cd $BADGR_APP_DIR
cp $BADGR_APP_DIR/apps/mainsite/settings_local.py.example $BADGR_APP_DIR/apps/mainsite/settings_local.py
pip install -r requirements-dev.txt
pip install gunicorn
npm install

npm install grunt
npm install -g grunt-cli
ln -s /usr/bin/nodejs /usr/bin/node
grunt dist
./manage.py migrate
echo "from django.contrib.auth import get_user_model; me = get_user_model(); me.objects.create_superuser('admin2@example.com', '$BADGR_ADMIN_USER', '$BADGR_ADMIN_USER_PWD'); quit()" | python manage.py shell
deactivate

# Setting up the badgr-server service
cd $BADGR_ROOT_DIR
mkdir -p $BADGR_ROOT_DIR/app/supervisor/conf.available.d
mkdir -p $BADGR_ROOT_DIR/app/supervisor/conf.d
mkdir -p $BADGR_ROOT_DIR/var/log/supervisor
mkdir -p $BADGR_ROOT_DIR/var/supervisor
mkdir -p $BADGR_ROOT_DIR/bin

#Copy supervisor.conf
curl --remote-name https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/supervisord.conf
#sudo wget https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/supervisord.conf
sudo cp supervisord.conf $BADGR_ROOT_DIR/app/supervisor/supervisord.conf
rm -r supervisord.conf

#sudo wget https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/wsgi.py
curl --remote-name https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/wsgi.py
sudo cp wsgi.py $BADGR_APP_DIR/wsgi.py
rm -r wsgi.py

curl --remote-name https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/gunicorn.py
cp gunicorn.py $BADGR_APP_DIR/gunicorn.py
rm -r gunicorn.py

curl --remote-name https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/badgr.conf
cp badgr.conf $BADGR_ROOT_DIR/app/supervisor/conf.available.d
ln -s $BADGR_ROOT_DIR/app/supervisor/conf.available.d/badgr.conf /usr/bin/node $BADGR_ROOT_DIR/app/supervisor/conf.d/badgr.conf
rm -r badgr.conf

curl --remote-name https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr/supervisorctl
cp supervisorctl $BADGR_ROOT_DIR/bin/supervisorctl
rm -r supervisorctl

sudo touch $BADGR_ROOT_DIR/var/supervisor/supervisor.sock
chmod 0700 $BADGR_ROOT_DIR/var/supervisor/supervisor.sock

cd $BADGR_ROOT_DIR/app/supervisor/
virtualenv venv/supervisor
source venv/supervisor/bin/activate
pip install supervisor
deactivate
$BADGR_ROOT_DIR/bin/supervisorctl restart all


#gunicorn -b 0.0.0.0:80 --workers=5 wsgi



