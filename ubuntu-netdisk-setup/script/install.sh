#!/bin/bash
#
# seafile-server-installer/seafile-server-ubuntu-16-04-amd64
#
# Copyright 2015, Alexander Jackson <alexander.jackson@seafile.de>
# Copyright 2016, Zheng Xie <xie.zheng@seafile.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
usage() {
   echo "Usage: $0 [-u <admin_email>] [-d <full_domain>] [-p <admin_pass>] [-s <seafile_version>]"
   echo "       admin_email is used to login seafile server, i.e. admin@seafile.local"
   echo "       full_domain is the full qualified domain name, i.e. mybox.southeastasia.cloudapp.azure.com"
   echo "       admin_pass is optional, if you do not specify it, a random string is generated"
   echo "       seafile_version is optional, default 6.1.1 is used"
   exit 1
}

if [[ $HOME == "" ]]; then
    export HOME=/root
fi

if [[ $SEAFILE_DEBUG != "" ]]; then
    set -x
fi
set -e

SEAFILE_VERSION="6.1.1"
SEAFILE_PRO=0
ZPOOL_NAME="MyDiskPool"
ZFS_DATASET="MyData"

while getopts ":u:p:d:s:" o; do
    case "${o}" in
     u)
       SEAFILE_ADMIN=${OPTARG}
       ;;
     p)
       SEAFILE_ADMIN_PW=${OPTARG}
       ;;
     d)
       IP_OR_DOMAIN=${OPTARG}
       ;;
     s)
       SEAFILE_VERSION=${OPTARG}
       ;;
     *)
       usage
       ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${SEAFILE_ADMIN}" ] || [ -z "${IP_OR_DOMAIN}" ]; then
   usage
fi

clear
cat <<EOF

  This script installs the community edition of the Seafile Server on a Ubuntu 16.04 (Xenial) 64bit
  - Newest Seafile server version, MariaDB, Memcached, NGINX -
  -----------------------------------------------------------------

  This installer is meant to run on a freshly installed machine
  only. If you run it on a production server things can and
  probably will go terrible wrong and you will loose valuable
  data!

  For questions or suggestions please contact us at
  support@seafile.com

  -----------------------------------------------------------------

  Possible options:
  1 = Seafile Community (Free) Edition (CE)
  2 = Seafile Professional Edition (PRO)

EOF

if [[ ${SEAFILE_PRO} == "" ]]; then
    PS3="Which Seafile version would you like to install? "
    select SEAFILE_SERVER_VERSION in CE PRO ABORT; do
        case "${SEAFILE_SERVER_VERSION}" in
            ABORT)
                echo "Aborting"
                break
                ;;
            "")
                echo "$REPLY: Wrong value. Select 1 or 2."
                ;;
            *)
                if [[ ${SEAFILE_SERVER_VERSION} = "PRO" ]]; then
                    SEAFILE_PRO=1
                else
                    SEAFILE_PRO=0
                fi
                break
        esac
    done
fi

is_pro() {
    if [[ "$SEAFILE_PRO" == "1" ]]; then
        return 0
    else
        return 1
    fi
}

echo
if is_pro; then
    echo "This script will install Seafile Professional Edition for you."
else
    echo "This script will install Seafile Community Edition for you."
fi
echo

# -------------------------------------------
# Vars
# -------------------------------------------

TIME_ZONE=Asia/Shanghai

if is_pro; then
    SEAFILE_SERVER_PACKAGE=seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz
    if [[ ! -e /opt/$SEAFILE_SERVER_PACKAGE ]]; then
        echo
        echo "You must download \"$SEAFILE_SERVER_PACKAGE\" to the /opt/ folder before running this script!"
        echo
        exit 1
    fi
    INSTALLPATH=/opt/seafile/seafile-pro-server-${SEAFILE_VERSION}/
else
    SEAFILE_SERVER_PACKAGE=seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz
    SEAFILE_SERVER_PACKAGE_URL=https://download.seadrive.org/${SEAFILE_SERVER_PACKAGE}
    INSTALLPATH=/opt/seafile/seafile-server-${SEAFILE_VERSION}/
fi


# -------------------------------------------
# Ensure we are running the installer as root
# -------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "  Aborting because you are not root" ; exit 1
fi


# -------------------------------------------
# Abort if directory /opt/seafile/ exists
# -------------------------------------------
if [[ -d "/opt/seafile/" ]] ;
then
  echo "  Aborting because directory /opt/seafile/ already exist" ; exit 1
fi

# -------------------------------------------
# Additional requirements
# -------------------------------------------
apt-get update
apt-get install -y python2.7 sudo python-pip python-setuptools python-imaging python-mysqldb python-ldap python-urllib3 \
openjdk-8-jre memcached python-memcache pwgen curl openssl poppler-utils libpython2.7 libreoffice \
libreoffice-script-provider-python ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy nginx python-requests zfs

# -------------------------------------------
# Create seafile-data with the help of ZFS
# -------------------------------------------
zpool create -f ${ZPOOL_NAME} /dev/sdc
zpool set cachefile=/etc/zfs/zpool.cache ${ZPOOL_NAME}
zfs create ${ZPOOL_NAME}/${ZFS_DATASET}
zfs set compression=gzip ${ZPOOL_NAME}/${ZFS_DATASET}

rm /etc/nginx/sites-enabled/*

cat > /etc/nginx/sites-available/seafile.conf <<'EOF'
server {
      listen 80;
      server_name  "${SEAFILE_ADMIN}";

      proxy_set_header X-Forwarded-For $remote_addr;

      location / {
          fastcgi_pass    127.0.0.1:8000;
          fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
          fastcgi_param   PATH_INFO           $fastcgi_script_name;
          fastcgi_param   SERVER_PROTOCOL     $server_protocol;
          fastcgi_param   QUERY_STRING        $query_string;
          fastcgi_param   REQUEST_METHOD      $request_method;
          fastcgi_param   CONTENT_TYPE        $content_type;
          fastcgi_param   CONTENT_LENGTH      $content_length;
          fastcgi_param   SERVER_ADDR         $server_addr;
          fastcgi_param   SERVER_PORT         $server_port;
          fastcgi_param   SERVER_NAME         $server_name;
          fastcgi_param   REMOTE_ADDR         $remote_addr;

          access_log      /var/log/nginx/seahub.access.log;
          error_log       /var/log/nginx/seahub.error.log;
      }
      location /seafhttp {
          rewrite ^/seafhttp(.*)$ $1 break;
          proxy_pass http://127.0.0.1:8082;
          client_max_body_size 0;
          proxy_connect_timeout  36000s;
          proxy_read_timeout  36000s;
      }
      location /media {
          root /opt/seafile/seafile-server-latest/seahub;
      }
     location /seafdav {
        fastcgi_pass    127.0.0.1:8080;
        fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
        fastcgi_param   PATH_INFO           $fastcgi_script_name;
        fastcgi_param   SERVER_PROTOCOL     $server_protocol;
        fastcgi_param   QUERY_STRING        $query_string;
        fastcgi_param   REQUEST_METHOD      $request_method;
        fastcgi_param   CONTENT_TYPE        $content_type;
        fastcgi_param   CONTENT_LENGTH      $content_length;
        fastcgi_param   SERVER_ADDR         $server_addr;
        fastcgi_param   SERVER_PORT         $server_port;
        fastcgi_param   SERVER_NAME         $server_name;
        fastcgi_param   REMOTE_ADDR         $remote_addr;

        client_max_body_size 0;

        access_log      /var/log/nginx/seafdav.access.log;
        error_log       /var/log/nginx/seafdav.error.log;
    }
}
EOF

ln -sf /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf

service nginx restart


# -------------------------------------------
# MariaDB
# -------------------------------------------
if [[ -f "/root/.my.cnf" ]] ;
then
  echo "MariaDB installed before, skip this part"
  SQLROOTPW=`sed -n 's/password=//p' /root/.my.cnf`
else
  DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server

  SQLROOTPW=$(pwgen)

  mysqladmin -u root password $SQLROOTPW

  cat > /root/.my.cnf <<EOF
[client]
user=root
password=$SQLROOTPW
EOF

  chmod 600 /root/.my.cnf
fi

# -------------------------------------------
# Seafile init script
# -------------------------------------------
cat > /etc/init.d/seafile-server <<'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          seafile-server
# Required-Start:    $remote_fs $syslog mysql
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Seafile server
# Description:       Start Seafile server
### END INIT INFO

# Author: Alexander Jackson <alexander.jackson@seafile.com.de>

# Change the value of "seafile_dir" to your path of seafile installation
seafile_dir=/opt/seafile
script_path=${seafile_dir}/seafile-server-latest
seafile_init_log=${seafile_dir}/logs/seafile.init.log
seahub_init_log=${seafile_dir}/logs/seahub.init.log

# Change the value of fastcgi to true if fastcgi is to be used
fastcgi=true
# Set the port of fastcgi, default is 8000. Change it if you need different.
fastcgi_port=8000

case "$1" in
        start)
                ${script_path}/seafile.sh start >> ${seafile_init_log}
                if [  $fastcgi = true ];
                then
                        ${script_path}/seahub.sh start-fastcgi ${fastcgi_port} >> ${seahub_init_log}
                else
                        ${script_path}/seahub.sh start >> ${seahub_init_log}
                fi
        ;;
        restart)
                ${script_path}/seafile.sh restart >> ${seafile_init_log}
                if [  $fastcgi = true ];
                then
                        ${script_path}/seahub.sh restart-fastcgi ${fastcgi_port} >> ${seahub_init_log}
                else
                        ${script_path}/seahub.sh restart >> ${seahub_init_log}
                fi
        ;;
        stop)
                ${script_path}/seafile.sh $1 >> ${seafile_init_log}
                ${script_path}/seahub.sh $1 >> ${seahub_init_log}
        ;;
        *)
                echo "Usage: /etc/init.d/seafile-server {start|stop|restart}"
                exit 1
        ;;
esac
EOF

chmod +x /etc/init.d/seafile-server
update-rc.d seafile-server defaults


# -------------------------------------------
# Seafile
# -------------------------------------------
mkdir -p /opt/seafile/installed
cd /opt/seafile/
if ! is_pro && [[ ! -e /opt/${SEAFILE_SERVER_PACKAGE} ]]; then
    curl -OL ${SEAFILE_SERVER_PACKAGE_URL}
else
    cp /opt/${SEAFILE_SERVER_PACKAGE} .
fi
tar xzf ${SEAFILE_SERVER_PACKAGE}

mv ${SEAFILE_SERVER_PACKAGE} installed


# -------------------------------------------
# Seafile DB
# -------------------------------------------
if [[ -f "/opt/seafile.my.cnf" ]] ;
then
  echo "MariaDB installed before, skip this part"
  SQLSEAFILEPW=`sed -n 's/password=//p' /opt/seafile.my.cnf`
else
  SQLSEAFILEPW=$(pwgen)

  cat > /opt/seafile.my.cnf <<EOF
[client]
user=seafile
password=$SQLSEAFILEPW
EOF

  chmod 600 /opt/seafile.my.cnf
fi

# -------------------------------------------
# Go to /opt/seafile/seafile-pro-server-${SEAFILE_VERSION}
# -------------------------------------------
cd $INSTALLPATH

# -------------------------------------------
# Vars - Don't touch these unless you really know what you are doing!
# -------------------------------------------
TOPDIR=$(dirname "${INSTALLPATH}")
DEFAULT_CONF_DIR=${TOPDIR}/conf

if [[ ! -e /${ZPOOL_NAME}/${ZFS_DATASET}/seafile-data ]]; then
   SEAFILE_DATA_DIR=/${ZPOOL_NAME}/${ZFS_DATASET}/seafile-data
else
   SEAFILE_DATA_DIR=/${ZPOOL_NAME}/${ZFS_DATASET}/seafile-data`date +%Y%m%d%H%M%S`
fi
DEST_SETTINGS_PY=${TOPDIR}/conf/seahub_settings.py

mkdir -p ${DEFAULT_CONF_DIR}

# -------------------------------------------
# Create ccnet, seafile, seahub conf using setup script
# -------------------------------------------

./setup-seafile-mysql.sh auto -u seafile -w ${SQLSEAFILEPW} -r ${SQLROOTPW} -d $SEAFILE_DATA_DIR

# -------------------------------------------
# Configure Seafile WebDAV Server(SeafDAV)
# -------------------------------------------
sed -i 's/enabled = .*/enabled = true/' ${DEFAULT_CONF_DIR}/seafdav.conf
sed -i 's/fastcgi = .*/fastcgi = true/' ${DEFAULT_CONF_DIR}/seafdav.conf
sed -i 's/share_name = .*/share_name = \/seafdav/' ${DEFAULT_CONF_DIR}/seafdav.conf

# -------------------------------------------
# Configuring seahub_settings.py
# -------------------------------------------
cat >> ${DEST_SETTINGS_PY} <<EOF

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
    'LOCATION': '127.0.0.1:11211',
    }
}

# EMAIL_USE_TLS                       = False
# EMAIL_HOST                          = 'localhost'
# EMAIL_HOST_USER                     = ''
# EMAIL_HOST_PASSWORD                 = ''
# EMAIL_PORT                          = '25'
# DEFAULT_FROM_EMAIL                  = EMAIL_HOST_USER
# SERVER_EMAIL                        = EMAIL_HOST_USER

TIME_ZONE                           = '${TIME_ZONE}'
SITE_BASE                           = 'http://${IP_OR_DOMAIN}'
SITE_NAME                           = 'Seafile Server'
SITE_TITLE                          = 'Seafile Server'
SITE_ROOT                           = '/'
ENABLE_SIGNUP                       = False
ACTIVATE_AFTER_REGISTRATION         = False
SEND_EMAIL_ON_ADDING_SYSTEM_MEMBER  = True
SEND_EMAIL_ON_RESETTING_USER_PASSWD = True
CLOUD_MODE                          = False
FILE_PREVIEW_MAX_SIZE               = 30 * 1024 * 1024
SESSION_COOKIE_AGE                  = 60 * 60 * 24 * 7 * 2
SESSION_SAVE_EVERY_REQUEST          = False
SESSION_EXPIRE_AT_BROWSER_CLOSE     = False

FILE_SERVER_ROOT                    = 'http://${IP_OR_DOMAIN}/seafhttp'
EOF


# -------------------------------------------
# Backup check_init_admin.py befor applying changes
# -------------------------------------------
cp ${INSTALLPATH}/check_init_admin.py ${INSTALLPATH}/check_init_admin.py.backup


# -------------------------------------------
# Set admin credentials in check_init_admin.py
# -------------------------------------------
SEAFILE_ADMIN_PW=${SEAFILE_ADMIN_PW:-$(pwgen)}
eval "sed -i 's/= ask_admin_email()/= \"${SEAFILE_ADMIN}\"/' ${INSTALLPATH}/check_init_admin.py"
eval "sed -i 's/= ask_admin_password()/= \"${SEAFILE_ADMIN_PW}\"/' ${INSTALLPATH}/check_init_admin.py"

# -------------------------------------------
# Start and stop Seafile eco system. This generates the initial admin user.
# -------------------------------------------
${INSTALLPATH}/seafile.sh start
${INSTALLPATH}/seahub.sh start
sleep 2                         # sleep for a while, otherwise seahub will not be stopped
${INSTALLPATH}/seahub.sh stop
sleep 1
${INSTALLPATH}/seafile.sh stop


# -------------------------------------------
# Restore original check_init_admin.py
# -------------------------------------------
mv ${INSTALLPATH}/check_init_admin.py.backup ${INSTALLPATH}/check_init_admin.py

if is_pro; then
    PRO_PY=${INSTALLPATH}/pro/pro.py
    $PYTHON ${PRO_PY} setup --mysql --mysql_host=127.0.0.1 --mysql_port=3306 --mysql_user=seafile --mysql_password=${SQLSEAFILEPW} --mysql_db=seahub_db
    sed -i 's/enabled = false/enabled = true/' ${TOPDIR}/conf/seafevents.conf
fi

# -------------------------------------------
# Start seafile server
# -------------------------------------------
echo "Starting productive Seafile server"
service seafile-server start


# -------------------------------------------
# Final report
# -------------------------------------------
cat > ${TOPDIR}/aio_seafile-server.log<<EOF

  Your Seafile server is installed
  -----------------------------------------------------------------

  Server Address:      http://${IP_OR_DOMAIN}

  Seafile Admin:       ${SEAFILE_ADMIN}
  Admin Password:      ${SEAFILE_ADMIN_PW}

  Seafile Data Dir:    ${SEAFILE_DATA_DIR}

  Seafile DB Credentials:  Check /opt/seafile.my.cnf
  Root DB Credentials:     Check /root/.my.cnf

  This report is also saved to ${TOPDIR}/aio_seafile-server.log



  Next you should manually complete the following steps
  -----------------------------------------------------------------

  1) Run seafile-server-change-address to add your Seafile servers DNS name

  2) If this server is behind a firewall, you need to ensure that
     tcp port 80 is open.

  3) Seahub tries to send emails via the local server. Install and
     configure Postfix for this to work.




  Optional steps
  -----------------------------------------------------------------

  1) Check seahub_settings.py and customize it to fit your needs. Consult
     http://manual.seafile.com/config/seahub_settings_py.html for possible switches.

  2) Setup NGINX with official SSL certificate.

  3) Secure server with iptables based firewall. For instance: UFW or shorewall

  4) Harden system with port knocking, fail2ban, etc.

  5) Enable unattended installation of security updates. Check
     https://wiki.Ubuntu.org/UnattendedUpgrades for details.

  6) Implement a backup routine for your Seafile server.

  7) Update NGINX worker processes to reflect the number of CPU cores.




  Seafile support options
  -----------------------------------------------------------------

  For free community support visit:   https://bbs.seafile.com
  For paid commercial support visit:  https://seafile.com

EOF

chmod 600 ${TOPDIR}/aio_seafile-server.log

clear

cat ${TOPDIR}/aio_seafile-server.log