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
VIRTUAL_ENV="/tmp/bootstrap"
PYTHON_BIN="${VIRTUAL_ENV}/bin"

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

apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2 build-essential sudo git-core libmysqlclient-dev libffi-dev libssl-dev


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
