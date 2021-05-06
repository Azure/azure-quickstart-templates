#!/bin/bash
#
# seafile-server-installer/seafile-8.0_ubuntu
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

if [[ $HOME == "" ]]; then
    export HOME=/root
fi

if [[ $SEAFILE_DEBUG != "" ]]; then
    set -x
fi
set -e

if [[ "$#" -ne 1 ]]; then
    echo "You must specif Seafile version to install"
    echo "Like: $0 8.0.0"
    exit 1
fi

clear
cat <<EOF
  This script installs the community edition of the Seafile Server on a Ubuntu 16.04 (Xenial) 64bit
  - Newest Seafile server version, MariaDB, Memcached, NGINX -
  -----------------------------------------------------------------
  This installer is meant to run on a freshly installed machine
  only. If you run it on a production server things can and
  probably will go terribly wrong and you will lose valuable
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
SEAFILE_ADMIN=admin@seafile.local
SEAFILE_SERVER_USER=seafile
SEAFILE_SERVER_HOME=/opt/seafile
IP_OR_DOMAIN=127.0.0.1
SEAFILE_VERSION=$1
TIME_ZONE=Europe/Berlin

if is_pro; then
    SEAFILE_SERVER_PACKAGE=seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz
    if [[ ! -e /opt/$SEAFILE_SERVER_PACKAGE ]]; then
        echo
        echo "You must download \"$SEAFILE_SERVER_PACKAGE\" to the /opt/ folder before running this script!"
        echo
        exit 1
    fi
    INSTALLPATH=${SEAFILE_SERVER_HOME}/seafile-pro-server-${SEAFILE_VERSION}/
else
    SEAFILE_SERVER_PACKAGE=seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz
    SEAFILE_SERVER_PACKAGE_URL=https://download.seadrive.org/${SEAFILE_SERVER_PACKAGE}
    INSTALLPATH=${SEAFILE_SERVER_HOME}/seafile-server-${SEAFILE_VERSION}/
fi


# -------------------------------------------
# Ensure we are running the installer as root
# -------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "  Aborting because you are not root" ; exit 1
fi


# -------------------------------------------
# Abort if directory SEAFILE_SERVER_HOME exists
# -------------------------------------------
if [[ -d "${SEAFILE_SERVER_HOME}" ]] ;
then
  echo "  Aborting because directory ${SEAFILE_SERVER_HOME} already exist" ; exit 1
fi

# -------------------------------------------
# Abort if seafile user exists
# -------------------------------------------
if getent passwd ${SEAFILE_SERVER_USER} > /dev/null 2>&1 ;
then
  echo "Aborting because user ${SEAFILE_SERVER_USER} already exist" ; exit 1
fi

# -------------------------------------------
# Additional requirements
# -------------------------------------------
apt-get update

apt-get install -y python3 python3-setuptools python3-pip python3-ldap memcached openjdk-8-jre \
    libmemcached-dev libreoffice-script-provider-python libreoffice pwgen curl nginx libmysqlclient-dev

pip3 install --timeout=3600 django==2.2.* future mysqlclient pymysql Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    psd-tools django-pylibmc django-simple-captcha


service memcached start


# -------------------------------------------
# Setup Nginx
# -------------------------------------------

rm /etc/nginx/sites-enabled/*

cat > /etc/nginx/sites-available/seafile.conf << EOF
log_format seafileformat '\$http_x_forwarded_for \$remote_addr [\$time_local] "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_user_agent" \$upstream_response_time';
server {
    listen 80;
    server_name seafile.example.com;
    proxy_set_header X-Forwarded-For \$remote_addr;
    location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host \$host;
         proxy_set_header   X-Real-IP \$remote_addr;
         proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host \$server_name;
         proxy_set_header   X-Forwarded-Proto \$scheme;
         proxy_read_timeout  1200s;
         # used for view/edit office file via Office Online Server
         client_max_body_size 0;
         access_log      /var/log/nginx/seahub.access.log seafileformat;
         error_log       /var/log/nginx/seahub.error.log;
    }
    
    location /seafhttp {
         rewrite ^/seafhttp(.*)$ \$1 break;
         proxy_pass http://127.0.0.1:8082;
         client_max_body_size 0;
         proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
         proxy_connect_timeout  36000s;
         proxy_read_timeout  36000s;
        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
    }
    location /media {
        root ${SEAFILE_SERVER_HOME}/seafile-server-latest/seahub;
    }
    location /seafdav {
        proxy_pass         http://127.0.0.1:8080/seafdav;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host \$server_name;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_read_timeout  1200s;
        client_max_body_size 0;
        access_log      /var/log/nginx/seafdav.access.log seafileformat;
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
  service mysql start

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
cat > /etc/init.d/seafile-server << EOF
#!/bin/bash
### BEGIN INIT INFO
# Provides:          seafile-server
# Required-Start:    \$remote_fs \$syslog mysql
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Seafile server
# Description:       Start Seafile server
### END INIT INFO
# Author: Zheng Xie <xie.zheng@seafile.com>
# Change the value of "seafile_dir" to your path of seafile installation
user=${SEAFILE_SERVER_USER}
seafile_dir=${SEAFILE_SERVER_HOME}
script_path=\${seafile_dir}/seafile-server-latest
seafile_init_log=\${seafile_dir}/logs/seafile.init.log
seahub_init_log=\${seafile_dir}/logs/seahub.init.log
case "\$1" in
        start)
                sudo -u \${user} \${script_path}/seafile.sh start >> \${seafile_init_log}
                sudo -u \${user} \${script_path}/seahub.sh start >> \${seahub_init_log}
        ;;
        restart)
                sudo -u \${user} \${script_path}/seafile.sh restart >> \${seafile_init_log}
                sudo -u \${user} \${script_path}/seahub.sh restart >> \${seahub_init_log}
        ;;
        stop)
                sudo -u \${user} \${script_path}/seafile.sh \$1 >> \${seafile_init_log}
                sudo -u \${user} \${script_path}/seahub.sh \$1 >> \${seahub_init_log}
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
mkdir -p ${SEAFILE_SERVER_HOME}/installed
cd ${SEAFILE_SERVER_HOME}
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
# Add seafile user
# -------------------------------------------
useradd --system --comment "${SEAFILE_SERVER_USER}" ${SEAFILE_SERVER_USER} --home-dir  ${SEAFILE_SERVER_HOME}

# -------------------------------------------
# Go to /opt/seafile/seafile-pro-server-${SEAFILE_VERSION}
# -------------------------------------------
cd $INSTALLPATH

# -------------------------------------------
# Vars - Don't touch these unless you really know what you are doing!
# -------------------------------------------
TOPDIR=$(dirname "${INSTALLPATH}")
DEFAULT_CONF_DIR=${TOPDIR}/conf
SEAFILE_DATA_DIR=${TOPDIR}/seafile-data
DEST_SETTINGS_PY=${TOPDIR}/conf/seahub_settings.py

mkdir -p ${DEFAULT_CONF_DIR}

# -------------------------------------------
# Create ccnet, seafile, seahub conf using setup script
# -------------------------------------------

./setup-seafile-mysql.sh auto -u seafile -w ${SQLSEAFILEPW} -r ${SQLROOTPW}

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
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
    'locmem': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    },
}
COMPRESS_CACHE_BACKEND = 'locmem'
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
SEAFILE_ADMIN_PW=$(pwgen)
eval "sed -i 's/= ask_admin_email()/= \"${SEAFILE_ADMIN}\"/' ${INSTALLPATH}/check_init_admin.py"
eval "sed -i 's/= ask_admin_password()/= \"${SEAFILE_ADMIN_PW}\"/' ${INSTALLPATH}/check_init_admin.py"

# -------------------------------------------
# Start and stop Seafile eco system. This generates the initial admin user.
# -------------------------------------------
chown ${SEAFILE_SERVER_USER}:${SEAFILE_SERVER_USER} -R ${SEAFILE_SERVER_HOME}

su - seafile -c "${INSTALLPATH}/seafile.sh start"
wait
su - seafile -c "${INSTALLPATH}/seahub.sh start"
wait					# sleep for a while, otherwise seahub will not be stopped
su - seafile -c "${INSTALLPATH}/seahub.sh stop"
wait
su - seafile -c "${INSTALLPATH}/seafile.sh stop"
wait
sleep 1

# -------------------------------------------
# Restore original check_init_admin.py
# -------------------------------------------
mv ${INSTALLPATH}/check_init_admin.py.backup ${INSTALLPATH}/check_init_admin.py

if is_pro; then
    PRO_PY=${INSTALLPATH}/pro/pro.py
    $PYTHON ${PRO_PY} setup --mysql --mysql_host=127.0.0.1 --mysql_port=3306 --mysql_user=seafile --mysql_password=${SQLSEAFILEPW} --mysql_db=seahub_db
fi

# kill all process
sleep 1
service seafile-server stop
wait
sleep 1


# -------------------------------------------
# Fix permissions
# -------------------------------------------
chown ${SEAFILE_SERVER_USER}:${SEAFILE_SERVER_USER} -R ${SEAFILE_SERVER_HOME}
if [[ -d /tmp/seafile-office-output/ ]]; then
    chown ${SEAFILE_SERVER_USER}:${SEAFILE_SERVER_USER} -R /tmp/seafile-office-output/
fi

# -------------------------------------------
# Start seafile server
# -------------------------------------------
echo "Starting productive Seafile server"
service seafile-server restart
wait


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
  1) Log in to Seafile and configure your server domain via the system
     admin area if applicable.
  2) If this server is behind a firewall, you need to ensure that
     tcp port 80 is open.
  3) Seahub tries to send emails via the local server. Install and
     configure Postfix for this to work or
     check https://manual.seafile.com/config/sending_email.html
     for instructions on how to use an existing email account via SMTP.
  Optional steps
  -----------------------------------------------------------------
  1) Check seahub_settings.py and customize it to fit your needs. Consult
     http://manual.seafile.com/config/seahub_settings_py.html for possible switches.
  2) Setup NGINX with official SSL certificate, we suggest you use Let’s Encrypt. Check
     https://manual.seafile.com/deploy/https_with_nginx.html
  3) Secure server with iptables based firewall. For instance: UFW or shorewall
  4) Harden system with port knocking, fail2ban, etc.
  5) Enable unattended installation of security updates. Check
     https://wiki.Ubuntu.org/UnattendedUpgrades for details.
  6) Implement a backup routine for your Seafile server.
  7) Update NGINX worker processes to reflect the number of CPU cores.
  Seafile support options
  -----------------------------------------------------------------
  For free community support visit:   https://forum.seafile.com
  For paid commercial support visit:  https://seafile.com
EOF

chmod 600 ${TOPDIR}/aio_seafile-server.log

clear

cat ${TOPDIR}/aio_seafile-server.log