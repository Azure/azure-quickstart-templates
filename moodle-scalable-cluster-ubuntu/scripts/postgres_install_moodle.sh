#!/bin/bash

# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#parameters 
{
    moodleVersion=$1
    glusterNode=$2
    glusterVolume=$3
    siteFQDN=$4
    postgresIP=$5
    moodledbname=$6
    moodledbuser=$7
    moodledbpass=$8
    adminpass=$9
    pgadminlogin=$10
    pgadminpass=$11
    wabsacctname=$12
    wabsacctkey=$13
    azuremoodledbuser=$14
    redisDns=$15
    redisAuth=$16
    elasticVm1IP=$17

    echo $moodleVersion        >> /tmp/vars.txt
    echo $glusterNode          >> /tmp/vars.txt
    echo $glusterVolume        >> /tmp/vars.txt
    echo $siteFQDN             >> /tmp/vars.txt
    echo $postgresIP           >> /tmp/vars.txt
    echo $moodledbname         >> /tmp/vars.txt
    echo $moodledbuser         >> /tmp/vars.txt
    echo $moodledbpass         >> /tmp/vars.txt
    echo    $adminpass         >> /tmp/vars.txt
    echo $pgadminlogin         >> /tmp/vars.txt
    echo $pgadminpass          >> /tmp/vars.txt
    echo $wabsacctname         >> /tmp/vars.txt
    echo $wabsacctkey          >> /tmp/vars.txt
    echo $azuremoodledbuser    >> /tmp/vars.txt
    echo $redisDns             >> /tmp/vars.txt
    echo $redisAuth            >> /tmp/vars.txt
    echo $elasticVm1IP         >> /tmp/vars.txt

    # make sure system does automatic updates and fail2ban
    sudo apt-get -y update
    sudo apt-get -y install unattended-upgrades fail2ban

    # configure fail2ban
    cat <<EOF > /etc/fail2ban/jail.conf
# Fail2Ban configuration file.
#
# This file was composed for Debian systems from the original one
# provided now under /usr/share/doc/fail2ban/examples/jail.conf
# for additional examples.
#
# Comments: use '#' for comment lines and ';' for inline comments
#
# To avoid merges during upgrades DO NOT MODIFY THIS FILE
# and rather provide your changes in /etc/fail2ban/jail.local
#

# The DEFAULT allows a global definition of the options. They can be overridden
# in each jail afterwards.

[DEFAULT]

# "ignoreip" can be an IP address, a CIDR mask or a DNS host. Fail2ban will not
# ban a host which matches an address in this list. Several addresses can be
# defined using space separator.
ignoreip = 127.0.0.1/8

# "bantime" is the number of seconds that a host is banned.
bantime  = 600

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime = 600
maxretry = 3

# "backend" specifies the backend used to get files modification.
# Available options are "pyinotify", "gamin", "polling" and "auto".
# This option can be overridden in each jail as well.
#
# pyinotify: requires pyinotify (a file alteration monitor) to be installed.
#            If pyinotify is not installed, Fail2ban will use auto.
# gamin:     requires Gamin (a file alteration monitor) to be installed.
#            If Gamin is not installed, Fail2ban will use auto.
# polling:   uses a polling algorithm which does not require external libraries.
# auto:      will try to use the following backends, in order:
#            pyinotify, gamin, polling.
backend = auto

# "usedns" specifies if jails should trust hostnames in logs,
#   warn when reverse DNS lookups are performed, or ignore all hostnames in logs
#
# yes:   if a hostname is encountered, a reverse DNS lookup will be performed.
# warn:  if a hostname is encountered, a reverse DNS lookup will be performed,
#        but it will be logged as a warning.
# no:    if a hostname is encountered, will not be used for banning,
#        but it will be logged as info.
usedns = warn

#
# Destination email address used solely for the interpolations in
# jail.{conf,local} configuration files.
destemail = root@localhost

#
# Name of the sender for mta actions
sendername = Fail2Ban

#
# ACTIONS
#

# Default banning action (e.g. iptables, iptables-new,
# iptables-multiport, shorewall, etc) It is used to define
# action_* variables. Can be overridden globally or per
# section within jail.local file
banaction = iptables-multiport

# email action. Since 0.8.1 upstream fail2ban uses sendmail
# MTA for the mailing. Change mta configuration parameter to mail
# if you want to revert to conventional 'mail'.
mta = sendmail

# Default protocol
protocol = tcp

# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT

#
# Action shortcuts. To be used to define action parameter

# The simplest action to take: ban only
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]

# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]

# ban & send an e-mail with whois report and relevant log lines
# to the destemail.
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
               %(mta)s-whois-lines[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s", sendername="%(sendername)s"]

# Choose default action.  To change, just override value of 'action' with the
# interpolation to the chosen action shortcut (e.g.  action_mw, action_mwl, etc) in jail.local
# globally (section [DEFAULT]) or per specific section
action = %(action_)s

#
# JAILS
#

# Next jails corresponds to the standard configuration in Fail2ban 0.6 which
# was shipped in Debian. Enable any defined here jail by including
#
# [SECTION_NAME]
# enabled = true

#
# in /etc/fail2ban/jail.local.
#
# Optionally you may override any other parameter (e.g. banaction,
# action, port, logpath, etc) in that section within jail.local

[ssh]

enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6

[dropbear]

enabled  = false
port     = ssh
filter   = dropbear
logpath  = /var/log/auth.log
maxretry = 6

# Generic filter for pam. Has to be used with action which bans all ports
# such as iptables-allports, shorewall
[pam-generic]

enabled  = false
# pam-generic filter can be customized to monitor specific subset of 'tty's
filter   = pam-generic
# port actually must be irrelevant but lets leave it all for some possible uses
port     = all
banaction = iptables-allports
port     = anyport
logpath  = /var/log/auth.log
maxretry = 6

[xinetd-fail]

enabled   = false
filter    = xinetd-fail
port      = all
banaction = iptables-multiport-log
logpath   = /var/log/daemon.log
maxretry  = 2


[ssh-ddos]

enabled  = false
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 6


# Here we use blackhole routes for not requiring any additional kernel support
# to store large volumes of banned IPs

[ssh-route]

enabled = false
filter = sshd
action = route
logpath = /var/log/sshd.log
maxretry = 6

# Here we use a combination of Netfilter/Iptables and IPsets
# for storing large volumes of banned IPs
#
# IPset comes in two versions. See ipset -V for which one to use
# requires the ipset package and kernel support.
[ssh-iptables-ipset4]

enabled  = false
port     = ssh
filter   = sshd
banaction = iptables-ipset-proto4
logpath  = /var/log/sshd.log
maxretry = 6

[ssh-iptables-ipset6]

enabled  = false
port     = ssh
filter   = sshd
banaction = iptables-ipset-proto6
logpath  = /var/log/sshd.log
maxretry = 6


#
# HTTP servers
#

[apache]

enabled  = false
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 6

# default action is now multiport, so apache-multiport jail was left
# for compatibility with previous (<0.7.6-2) releases
[apache-multiport]

enabled   = false
port      = http,https
filter    = apache-auth
logpath   = /var/log/apache*/*error.log
maxretry  = 6

[apache-noscript]

enabled  = false
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-overflows]

enabled  = false
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 2

# Ban attackers that try to use PHP's URL-fopen() functionality
# through GET/POST variables. - Experimental, with more than a year
# of usage in production environments.

[php-url-fopen]

enabled = false
port    = http,https
filter  = php-url-fopen
logpath = /var/www/*/logs/access_log

# A simple PHP-fastcgi jail which works with lighttpd.
# If you run a lighttpd server, then you probably will
# find these kinds of messages in your error_log:
#   ALERT – tried to register forbidden variable ‘GLOBALS’
#   through GET variables (attacker '1.2.3.4', file '/var/www/default/htdocs/index.php')

[lighttpd-fastcgi]

enabled = false
port    = http,https
filter  = lighttpd-fastcgi
logpath = /var/log/lighttpd/error.log

# Same as above for mod_auth
# It catches wrong authentifications

[lighttpd-auth]

enabled = false
port    = http,https
filter  = suhosin
logpath = /var/log/lighttpd/error.log

[nginx-http-auth]

enabled = false
filter  = nginx-http-auth
port    = http,https
logpath = /var/log/nginx/error.log

# Monitor roundcube server

[roundcube-auth]

enabled  = false
filter   = roundcube-auth
port     = http,https
logpath  = /var/log/roundcube/userlogins


[sogo-auth]

enabled  = false
filter   = sogo-auth
port     = http, https
# without proxy this would be:
# port    = 20000
logpath  = /var/log/sogo/sogo.log


#
# FTP servers
#

[vsftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = vsftpd
logpath  = /var/log/vsftpd.log
# or overwrite it in jails.local to be
# logpath = /var/log/auth.log
# if you want to rely on PAM failed login attempts
# vsftpd's failregex should match both of those formats
maxretry = 6


[proftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = proftpd
logpath  = /var/log/proftpd/proftpd.log
maxretry = 6


[pure-ftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = pure-ftpd
logpath  = /var/log/syslog
maxretry = 6


[wuftpd]

enabled  = false
port     = ftp,ftp-data,ftps,ftps-data
filter   = wuftpd
logpath  = /var/log/syslog
maxretry = 6


#
# Mail servers
#

[postfix]

enabled  = false
port     = smtp,ssmtp,submission
filter   = postfix
logpath  = /var/log/mail.log


[couriersmtp]

enabled  = false
port     = smtp,ssmtp,submission
filter   = couriersmtp
logpath  = /var/log/mail.log


#
# Mail servers authenticators: might be used for smtp,ftp,imap servers, so
# all relevant ports get banned
#

[courierauth]

enabled  = false
port     = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter   = courierlogin
logpath  = /var/log/mail.log


[sasl]

enabled  = false
port     = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter   = postfix-sasl
# You might consider monitoring /var/log/mail.warn instead if you are
# running postfix since it would provide the same log lines at the
# "warn" level but overall at the smaller filesize.
logpath  = /var/log/mail.log

[dovecot]

enabled = false
port    = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
filter  = dovecot
logpath = /var/log/mail.log

# To log wrong MySQL access attempts add to /etc/my.cnf:
# log-error=/var/log/mysqld.log
# log-warning = 2
[mysqld-auth]

enabled  = false
filter   = mysqld-auth
port     = 3306
logpath  = /var/log/mysqld.log


# DNS Servers


# These jails block attacks against named (bind9). By default, logging is off
# with bind9 installation. You will need something like this:
#
# logging {
#     channel security_file {
#         file "/var/log/named/security.log" versions 3 size 30m;
#         severity dynamic;
#         print-time yes;
#     };
#     category security {
#         security_file;
#     };
# };
#
# in your named.conf to provide proper logging

# !!! WARNING !!!
#   Since UDP is connection-less protocol, spoofing of IP and imitation
#   of illegal actions is way too simple.  Thus enabling of this filter
#   might provide an easy way for implementing a DoS against a chosen
#   victim. See
#    http://nion.modprobe.de/blog/archives/690-fail2ban-+-dns-fail.html
#   Please DO NOT USE this jail unless you know what you are doing.
#[named-refused-udp]
#
#enabled  = false
#port     = domain,953
#protocol = udp
#filter   = named-refused
#logpath  = /var/log/named/security.log

[named-refused-tcp]

enabled  = false
port     = domain,953
protocol = tcp
filter   = named-refused
logpath  = /var/log/named/security.log

# Multiple jails, 1 per protocol, are necessary ATM:
# see https://github.com/fail2ban/fail2ban/issues/37
[asterisk-tcp]

enabled  = false
filter   = asterisk
port     = 5060,5061
protocol = tcp
logpath  = /var/log/asterisk/messages

[asterisk-udp]

enabled  = false
filter	 = asterisk
port     = 5060,5061
protocol = udp
logpath  = /var/log/asterisk/messages


# Jail for more extended banning of persistent abusers
# !!! WARNING !!!
#   Make sure that your loglevel specified in fail2ban.conf/.local
#   is not at DEBUG level -- which might then cause fail2ban to fall into
#   an infinite loop constantly feeding itself with non-informative lines
[recidive]

enabled  = false
filter   = recidive
logpath  = /var/log/fail2ban.log
action   = iptables-allports[name=recidive]
           sendmail-whois-lines[name=recidive, logpath=/var/log/fail2ban.log]
bantime  = 604800  ; 1 week
findtime = 86400   ; 1 day
maxretry = 5
EOF

    # create gluster mount point
    mkdir -p /moodle

    export DEBIAN_FRONTEND=noninteractive

    # configure gluster repository & install gluster client
    sudo add-apt-repository ppa:gluster/glusterfs-3.8 -y                     >> /tmp/apt1.log
    sudo apt-get -y update                                                   >> /tmp/apt2.log
    sudo apt-get -y --force-yes install rsyslog glusterfs-client postgresql-client git    >> /tmp/apt3.log

    # install azure cli & setup container
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list

    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 >> /tmp/apt4.log
    sudo apt-get -y install apt-transport-https >> /tmp/apt4.log
    sudo apt-get -y update > /dev/null
    sudo apt-get -y install azure-cli >> /tmp/apt4.log

    az storage container create \
        --name objectfs \
        --account-name $wabsacctname \
        --account-key $wabsacctkey \
        --public-access off \
        --fail-on-exist >> /tmp/wabs.log

    az storage container policy create \
        --account-name $wabsacctname \
        --account-key $wabsacctkey \
        --container-name objectfs \
        --name readwrite \
        --start $(date --date="1 day ago" +%F) \
        --expiry $(date --date="2199-01-01" +%F) \
        --permissions rw >> /tmp/wabs.log

    sas=$(az storage container generate-sas \
        --account-name $wabsacctname \
        --account-key $wabsacctkey \
        --name objectfs \
        --policy readwrite \
        --output tsv)

    # mount gluster files system
    echo -e '\n\rInstalling GlusterFS on '$glusterNode':/'$glusterVolume '/moodle\n\r' 
    sudo mount -t glusterfs $glusterNode:/$glusterVolume /moodle

    
    
    # install pre-requisites
    sudo apt-get install -y --fix-missing python-software-properties unzip

    # install the entire stack
    sudo apt-get -y  --force-yes install nginx php-fpm varnish >> /tmp/apt5a.log
    sudo apt-get -y  --force-yes install php php-cli php-curl php-zip >> /tmp/apt5b.log

    # Moodle requirements
    sudo apt-get -y update > /dev/null
    sudo apt-get install -y --force-yes graphviz aspell php-common php-soap php-json php-redis > /tmp/apt6.log
    sudo apt-get install -y --force-yes php-bcmath php-gd php-pgsql php-xmlrpc php-intl php-xml php-bz2 >> /tmp/apt6.log


    # Set up initial moodle dirs
    mkdir -p /moodle/html
    mkdir -p /moodle/certs
    mkdir -p /moodle/moodledata
    chown -R www-data.www-data /moodle

    # install Moodle 
    echo '#!/bin/bash
    cd /tmp

    # downloading moodle 
    /usr/bin/curl -k --max-redirs 10 https://github.com/moodle/moodle/archive/'$moodleVersion'.zip -L -o moodle.zip
    /usr/bin/unzip -q moodle.zip
    /bin/mv -v moodle-'$moodleVersion' /moodle/html/moodle

    # Commented out as the plugin is not available
    # install Office 365 plugins
    #if [ "$installOfficePlugins" = "True" ]; then
    #        curl -k --max-redirs 10 https://github.com/Microsoft/o365-moodle/archive/'$moodleVersion'.zip -L -o o365.zip
    #        unzip -q o365.zip
    #        cp -r o365-moodle-'$moodleVersion'/* /moodle/html/moodle
    #        rm -rf o365-moodle-'$moodleVersion'
    #fi

    # Install ElasticSearch plugin
    /usr/bin/curl -k --max-redirs 10 https://github.com/catalyst/moodle-search_elastic/archive/master.zip -L -o plugin-elastic.zip
    /usr/bin/unzip -q plugin-elastic.zip
    /bin/mkdir -p /moodle/html/moodle/search/engine/elastic
    /bin/cp -r moodle-search_elastic-master/* /moodle/html/moodle/search/engine/elastic
    /bin/rm -rf moodle-search_elastic-master

    # Install ElasticSearch plugin dependency
    /usr/bin/curl -k --max-redirs 10 https://github.com/catalyst/moodle-local_aws/archive/master.zip -L -o local-aws.zip
    /usr/bin/unzip -q local-aws.zip
    /bin/mkdir -p /moodle/html/moodle/local/aws
    /bin/cp -r moodle-local_aws-master/* /moodle/html/moodle/local/aws

    # Install the ObjectFS plugin
    /usr/bin/curl -k --max-redirs 10 https://github.com/catalyst/moodle-tool_objectfs/archive/master.zip -L -o plugin-objectfs.zip
    /usr/bin/unzip -q plugin-objectfs.zip
    /bin/mkdir -p /moodle/html/moodle/admin/tool/objectfs
    /bin/cp -r moodle-tool_objectfs-master/* /moodle/html/moodle/admin/tool/objectfs
    /bin/rm -rf moodle-tool_objectfs-master

    # Install the ObjectFS Azure library
    /usr/bin/curl -k --max-redirs 10 https://github.com/catalyst/moodle-local_azure_storage/archive/master.zip -L -o plugin-azurelibrary.zip
    /usr/bin/unzip -q plugin-azurelibrary.zip
    /bin/mkdir -p /moodle/html/moodle/local/azure_storage
    /bin/cp -r moodle-local_azure_storage-master/* /moodle/html/moodle/local/azure_storage
    /bin/rm -rf moodle-local_azure_storage-master
    ' > /tmp/setup-moodle.sh 

    chmod 755 /tmp/setup-moodle.sh
    sudo -u www-data /tmp/setup-moodle.sh >> /tmp/setupmoodle.log

    # create cron entry
    # It is scheduled for once per day. It can be changed as needed.
    echo '* * * * * www-data /usr/bin/php /moodle/html/moodle/admin/cli/cron.php 2>&1 | /usr/bin/logger -p local2.notice -t moodle' > /etc/cron.d/moodle-cron

    # Build nginx config
    cat <<EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes 2;
pid /run/nginx.pid;

events {
	worker_connections 768;
}

http {

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  client_max_body_size 0;
  proxy_max_temp_file_size 0;
  server_names_hash_bucket_size  128;
  fastcgi_buffers 16 16k; 
  fastcgi_buffer_size 32k;
  proxy_buffering off;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  set_real_ip_from   127.0.0.1;
  real_ip_header      X-Forwarded-For;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
  ssl_prefer_server_ciphers on;

  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 6;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

  map \$http_x_forwarded_proto \$fastcgi_https {                                                                                          
    default \$https;                                                                                                                   
    http '';                                                                                                                          
    https on;                                                                                                                         
  }   

  log_format moodle_combined '\$remote_addr - \$upstream_http_x_moodleuser [\$time_local] '
                             '"\$request" \$status \$body_bytes_sent '
                             '"\$http_referer" "\$http_user_agent"';


  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
EOF

    cat <<EOF >> /etc/nginx/sites-enabled/${siteFQDN}.conf
server {
        listen 81 default;
        server_name ${siteFQDN};
        root /moodle/html/moodle;
	index index.php index.html index.htm;

        # Log to syslog
        error_log syslog:server=localhost,facility=local1,severity=error,tag=moodle;
        access_log syslog:server=localhost,facility=local1,severity=notice,tag=moodle moodle_combined;

        # Log XFF IP instead of varnish
        set_real_ip_from    10.0.0.0/8;
        set_real_ip_from    127.0.0.1;
        set_real_ip_from    172.16.0.0/12;
        set_real_ip_from    192.168.0.0/16;
        real_ip_header      X-Forwarded-For;
        real_ip_recursive   on;


        # Redirect to https
        if (\$http_x_forwarded_proto != https) {
                return 301 https://\$server_name\$request_uri;
        }
        rewrite ^/(.*\.php)(/)(.*)$ /\$1?file=/\$3 last;


        # Filter out php-fpm status page
        location ~ ^/server-status {
            return 404;
        }

	location / {
		try_files \$uri \$uri/index.php?\$query_string;
	}
 
        location ~ [^/]\.php(/|$) {
          fastcgi_split_path_info ^(.+?\.php)(/.*)$;
          if (!-f \$document_root\$fastcgi_script_name) {
                  return 404;
          }
 
          fastcgi_buffers 16 16k;
          fastcgi_buffer_size 32k;
          fastcgi_param   SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
          fastcgi_pass unix:/run/php/php7.0-fpm.sock;
          fastcgi_read_timeout 3600;
          fastcgi_index index.php;
          include fastcgi_params;
        }
}

server {
        listen 443 ssl;
        root /moodle/html/moodle;
	index index.php index.html index.htm;

        ssl on;
        ssl_certificate /moodle/certs/nginx.crt;
        ssl_certificate_key /moodle/certs/nginx.key;

        # Log to syslog
        error_log syslog:server=localhost,facility=local1,severity=error,tag=moodle;
        access_log syslog:server=localhost,facility=local1,severity=notice,tag=moodle moodle_combined;

        # Log XFF IP instead of varnish
        set_real_ip_from    10.0.0.0/8;
        set_real_ip_from    127.0.0.1;
        set_real_ip_from    172.16.0.0/12;
        set_real_ip_from    192.168.0.0/16;
        real_ip_header      X-Forwarded-For;
        real_ip_recursive   on;

        location / {
          proxy_set_header Host \$host;
          proxy_set_header HTTP_REFERER \$http_referer;
          proxy_set_header X-Forwarded-Host \$host;
          proxy_set_header X-Forwarded-Server \$host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_pass http://localhost:80;
        }
}
EOF

    echo -e "Generating SSL self-signed certificate"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /moodle/certs/nginx.key -out /moodle/certs/nginx.crt -subj "/C=BR/ST=SP/L=SaoPaulo/O=IT/CN=$siteFQDN"

   # php config 
   PhpIni=/etc/php/7.0/fpm/php.ini
   sed -i "s/memory_limit.*/memory_limit = 512M/" $PhpIni
   sed -i "s/max_execution_time.*/max_execution_time = 18000/" $PhpIni
   sed -i "s/max_input_vars.*/max_input_vars = 100000/" $PhpIni
   sed -i "s/max_input_time.*/max_input_time = 600/" $PhpIni
   sed -i "s/upload_max_filesize.*/upload_max_filesize = 1024M/" $PhpIni
   sed -i "s/post_max_size.*/post_max_size = 1056M/" $PhpIni
   sed -i "s/;opcache.use_cwd.*/opcache.use_cwd = 1/" $PhpIni
   sed -i "s/;opcache.validate_timestamps.*/opcache.validate_timestamps = 1/" $PhpIni
   sed -i "s/;opcache.save_comments.*/opcache.save_comments = 1/" $PhpIni
   sed -i "s/;opcache.enable_file_override.*/opcache.enable_file_override = 0/" $PhpIni
   sed -i "s/;opcache.enable.*/opcache.enable = 1/" $PhpIni
   sed -i "s/;opcache.memory_consumption.*/opcache.memory_consumption = 256/" $PhpIni
   sed -i "s/;opcache.max_accelerated_files.*/opcache.max_accelerated_files = 8000/" $PhpIni

   # fpm config - overload this 
   cat <<EOF > /etc/php/7.0/fpm/pool.d/www.conf
[www]
user = www-data
group = www-data
listen = /run/php/php7.0-fpm.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 3000
pm.start_servers = 20 
pm.min_spare_servers = 22 
pm.max_spare_servers = 30 
EOF
   

   # Remove the default site. Moodle is the only site we want
   rm -f /etc/nginx/sites-enabled/default

   # restart Nginx
    sudo service nginx restart 

   # Configure varnish startup for 16.04
   VARNISHSTART="ExecStart=\/usr\/sbin\/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f \/etc\/varnish\/moodle.vcl -S \/etc\/varnish\/secret -s malloc,1024m -p thread_pool_min=200 -p thread_pool_max=4000 -p thread_pool_add_delay=2 -p timeout_linger=100 -p timeout_idle=30 -p send_timeout=1800 -p thread_pools=4 -p http_max_hdr=512 -p workspace_backend=512k"
   sed -i "s/^ExecStart.*/${VARNISHSTART}/" /lib/systemd/system/varnish.service

   # Configure varnish VCL for moodle
   cat <<EOF >> /etc/varnish/moodle.vcl
vcl 4.0;

import std;
import directors;
backend default {
    .host = "localhost";
    .port = "81";
    .first_byte_timeout = 3600s;
    .connect_timeout = 600s;
    .between_bytes_timeout = 600s;
}

sub vcl_recv {
    # Varnish does not support SPDY or HTTP/2.0 untill we upgrade to Varnish 5.0
    if (req.method == "PRI") {
        return (synth(405));
    }

    if (req.restarts == 0) {
      if (req.http.X-Forwarded-For) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
      } else {
        set req.http.X-Forwarded-For = client.ip;
      }
    }

    # Non-RFC2616 or CONNECT HTTP requests methods filtered. Pipe requests directly to backend
    if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE") {
      return (pipe);
    }

    # Varnish don't mess with healthchecks
    if (req.url ~ "^/admin/tool/heartbeat" || req.url ~ "^/healthcheck.php")
    {
        return (pass);
    }

    # Pipe requests to backup.php straight to backend - prevents problem with progress bar long polling 503 problem
    # This is here because backup.php is POSTing to itself - Filter before !GET&&!HEAD
    if (req.url ~ "^/backup/backup.php")
    {
        return (pipe);
    }

    # Varnish only deals with GET and HEAD by default. If request method is not GET or HEAD, pass request to backend
    if (req.method != "GET" && req.method != "HEAD") {
      return (pass);
    }

    ### Rules for Moodle and Totara sites ###
    # Moodle doesn't require Cookie to serve following assets. Remove Cookie header from request, so it will be looked up.
    if ( req.url ~ "^/altlogin/.+/.+\.(png|jpg|jpeg|gif|css|js|webp)$" ||
         req.url ~ "^/pix/.+\.(png|jpg|jpeg|gif)$" ||
         req.url ~ "^/theme/font.php" ||
         req.url ~ "^/theme/image.php" ||
         req.url ~ "^/theme/javascript.php" ||
         req.url ~ "^/theme/jquery.php" ||
         req.url ~ "^/theme/styles.php" ||
         req.url ~ "^/theme/yui" ||
         req.url ~ "^/lib/javascript.php/-1/" ||
         req.url ~ "^/lib/requirejs.php/-1/"
        )
    {
        set req.http.X-Long-TTL = "86400";
        unset req.http.Cookie;
        return(hash);
    }

    # Perform lookup for selected assets that we know are static but Moodle still needs a Cookie
    if(  req.url ~ "^/theme/.+\.(png|jpg|jpeg|gif|css|js|webp)" ||
         req.url ~ "^/lib/.+\.(png|jpg|jpeg|gif|css|js|webp)" ||
         req.url ~ "^/pluginfile.php/[0-9]+/course/overviewfiles/.+\.(?i)(png|jpg)$"
      )
    {
         # Set internal temporary header, based on which we will do things in vcl_backend_response
         set req.http.X-Long-TTL = "86400";
         return (hash);
    }

    # Serve requests to SCORM checknet.txt from varnish. Have to remove get parameters. Response body always contains "1"
    if ( req.url ~ "^/lib/yui/build/moodle-core-checknet/assets/checknet.txt" )
    {
        set req.url = regsub(req.url, "(.*)\?.*", "\1");
        unset req.http.Cookie; # Will go to hash anyway at the end of vcl_recv
        set req.http.X-Long-TTL = "86400";
        return(hash);
    }

    # Requests containing "Cookie" or "Authorization" headers will not be cached
    if (req.http.Authorization || req.http.Cookie) {
        return (pass);
    }

    # Almost everything in Moodle correctly serves Cache-Control headers, if
    # needed, which varnish will honor, but there are some which don't. Rather
    # than explicitly finding them all and listing them here we just fail safe
    # and don't cache unknown urls that get this far.
    return (pass);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    # 
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    # We know these assest are static, let's set TTL >0 and allow client caching
    if ( beresp.http.Cache-Control && bereq.http.X-Long-TTL && beresp.ttl < std.duration(bereq.http.X-Long-TTL + "s", 1s) && !beresp.http.WWW-Authenticate )
    { # If max-age < defined in X-Long-TTL header
        set beresp.http.X-Orig-Pragma = beresp.http.Pragma; unset beresp.http.Pragma;
        set beresp.http.X-Orig-Cache-Control = beresp.http.Cache-Control;
        set beresp.http.Cache-Control = "public, max-age="+bereq.http.X-Long-TTL+", no-transform";
        set beresp.ttl = std.duration(bereq.http.X-Long-TTL + "s", 1s);
        unset bereq.http.X-Long-TTL;
    }
    else if( !beresp.http.Cache-Control && bereq.http.X-Long-TTL && !beresp.http.WWW-Authenticate ) {
        set beresp.http.X-Orig-Pragma = beresp.http.Pragma; unset beresp.http.Pragma;
        set beresp.http.Cache-Control = "public, max-age="+bereq.http.X-Long-TTL+", no-transform";
        set beresp.ttl = std.duration(bereq.http.X-Long-TTL + "s", 1s);
        unset bereq.http.X-Long-TTL;
    }
    else { # Don't touch headers if max-age > defined in X-Long-TTL header
        unset bereq.http.X-Long-TTL;
    }

    # Here we set X-Trace header, prepending it to X-Trace header received from backend. Useful for troubleshooting
    if(beresp.http.x-trace && !beresp.was_304) {
        set beresp.http.X-Trace = regsub(server.identity, "^([^.]+),?.*$", "\1")+"->"+regsub(beresp.backend.name, "^(.+)\((?:[0-9]{1,3}\.){3}([0-9]{1,3})\)","\1(\2)")+"->"+beresp.http.X-Trace;
    }
    else {
        set beresp.http.X-Trace = regsub(server.identity, "^([^.]+),?.*$", "\1")+"->"+regsub(beresp.backend.name, "^(.+)\((?:[0-9]{1,3}\.){3}([0-9]{1,3})\)","\1(\2)");
    }

    # Gzip JS, CSS is done at the ngnix level doing it here dosen't respect the no buffer requsets
    # if (beresp.http.content-type ~ "application/javascript.*" || beresp.http.content-type ~ "text") {
    #    set beresp.do_gzip = true;
    #}
}

sub vcl_deliver {

    # Revert back to original Cache-Control header before delivery to client
    if (resp.http.X-Orig-Cache-Control)
    {
        set resp.http.Cache-Control = resp.http.X-Orig-Cache-Control;
        unset resp.http.X-Orig-Cache-Control;
    }

    # Revert back to original Pragma header before delivery to client
    if (resp.http.X-Orig-Pragma)
    {
        set resp.http.Pragma = resp.http.X-Orig-Pragma;
        unset resp.http.X-Orig-Pragma;
    }

    # (Optional) X-Cache HTTP header will be added to responce, indicating whether object was retrieved from backend, or served from cache
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }

    # Set X-AuthOK header when totara/varnsih authentication succeeded
    if (req.http.X-AuthOK) {
        set resp.http.X-AuthOK = req.http.X-AuthOK;
    }

    # If desired "Via: 1.1 Varnish-v4" response header can be removed from response
    unset resp.http.Via;
    unset resp.http.Server;

    return(deliver);
}

sub vcl_backend_error {
    # More comprehensive varnish error page. Display time, instance hostname, host header, url for easier troubleshooting.
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    set beresp.http.Retry-After = "5";
    synthetic( {"
  <!DOCTYPE html>
  <html>
    <head>
      <title>"} + beresp.status + " " + beresp.reason + {"</title>
    </head>
    <body>
      <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
      <p>"} + beresp.reason + {"</p>
      <h3>Guru Meditation:</h3>
      <p>Time: "} + now + {"</p>
      <p>Node: "} + server.hostname + {"</p>
      <p>Host: "} + bereq.http.host + {"</p>
      <p>URL: "} + bereq.url + {"</p>
      <p>XID: "} + bereq.xid + {"</p>
      <hr>
      <p>Varnish cache server
    </body>
  </html>
  "} );
   return (deliver);
}

sub vcl_synth {

    #Redirect using '301 - Permanent Redirect', permanent redirect
    if (resp.status == 851) { 
        set resp.http.Location = req.http.x-redir;
        set resp.http.X-Varnish-Redirect = true;
        set resp.status = 301;
        return (deliver);
    }

    #Redirect using '302 - Found', temporary redirect
    if (resp.status == 852) { 
        set resp.http.Location = req.http.x-redir;
        set resp.http.X-Varnish-Redirect = true;
        set resp.status = 302;
        return (deliver);
    }

    #Redirect using '307 - Temporary Redirect', !GET&&!HEAD requests, dont change method on redirected requests
    if (resp.status == 857) { 
        set resp.http.Location = req.http.x-redir;
        set resp.http.X-Varnish-Redirect = true;
        set resp.status = 307;
        return (deliver);
    }

    #Respond with 403 - Forbidden
    if (resp.status == 863) {
        set resp.http.X-Varnish-Error = true;
        set resp.status = 403;
        return (deliver);
    }
}
EOF

    # Restart Varnish
    systemctl daemon-reload
    service varnish restart

    # Create postgres db
    echo "${postgresIP}:5432:postgres:${pgadminlogin}:${pgadminpass}" > /root/.pgpass
    chmod 600 /root/.pgpass
    psql -h $postgresIP -U $pgadminlogin -c "CREATE DATABASE ${moodledbname};" postgres
    psql -h $postgresIP -U $pgadminlogin -c "CREATE USER ${moodledbuser} WITH PASSWORD '${moodledbpass}';" postgres
    psql -h $postgresIP -U $pgadminlogin -c "GRANT ALL ON DATABASE ${moodledbname} TO ${moodledbuser};" postgres
    rm -f /root/.pgpass

    # Master config for syslog
    mkdir /var/log/sitelogs
    chown syslog.adm /var/log/sitelogs
    cat <<EOF >> /etc/rsyslog.conf
\$ModLoad imudp
\$UDPServerRun 514
EOF
    cat <<EOF >> /etc/rsyslog.d/40-sitelogs.conf
local1.*   /var/log/sitelogs/moodle/access.log
local1.err   /var/log/sitelogs/moodle/error.log
local2.*   /var/log/sitelogs/moodle/cron.log
EOF
    service rsyslog restart

    # Fire off moodle setup
    echo -e "cd /tmp; sudo -u www-data /usr/bin/php /moodle/html/moodle/admin/cli/install.php --chmod=770 --lang=en_us --wwwroot=https://"$siteFQDN" --dataroot=/moodle/moodledata --dbhost="$postgresIP" --dbname="$moodledbname" --dbuser="$azuremoodledbuser" --dbpass="$moodledbpass" --dbtype=pgsql --fullname='Moodle LMS' --shortname='Moodle' --adminuser=admin --adminpass="$adminpass" --adminemail=admin@"$siteFQDN" --non-interactive --agree-license --allow-unstable || true "
    cd /tmp; sudo -u www-data /usr/bin/php /moodle/html/moodle/admin/cli/install.php --chmod=770 --lang=en_us --wwwroot=https://$siteFQDN   --dataroot=/moodle/moodledata --dbhost=$postgresIP   --dbname=$moodledbname   --dbuser=$azuremoodledbuser   --dbpass=$moodledbpass   --dbtype=pgsql --fullname='Moodle LMS' --shortname='Moodle' --adminuser=admin --adminpass=$adminpass   --adminemail=admin@$siteFQDN   --non-interactive --agree-license --allow-unstable || true

    # Add the ObjectFS configuration to Moodle.
    echo "${postgresIP}:5432:${moodledbname}:${azuremoodledbuser}:${moodledbpass}" > /root/.pgpass
    chmod 600 /root/.pgpass
    psql -h $postgresIP -U $azuremoodledbuser -c "INSERT INTO mdl_config_plugins (plugin, name, value) VALUES ('tool_objectfs', 'enabletasks', 1);" $moodledbname
    psql -h $postgresIP -U $azuremoodledbuser -c "INSERT INTO mdl_config_plugins (plugin, name, value) VALUES ('tool_objectfs', 'filesystem', '\tool_objectfs\azure_file_system');" $moodledbname
    psql -h $postgresIP -U $azuremoodledbuser -c "INSERT INTO mdl_config_plugins (plugin, name, value) VALUES ('tool_objectfs', 'azure_accountname', '$wabsacctname');" $moodledbname
    psql -h $postgresIP -U $azuremoodledbuser -c "INSERT INTO mdl_config_plugins (plugin, name, value) VALUES ('tool_objectfs', 'azure_container', 'objectfs');" $moodledbname
    psql -h $postgresIP -U $azuremoodledbuser -c "INSERT INTO mdl_config_plugins (plugin, name, value) VALUES ('tool_objectfs', 'azure_sastoken', '$sas');" $moodledbname

    echo -e "\n\rDone! Installation completed!\n\r"

   # create redis configuration in /moodle/moodledata/muc/config.php
   cat <<EOF > /moodle/moodledata/muc/config.php
<?php defined('MOODLE_INTERNAL') || die();
 \$configuration = array (
  'siteidentifier' => '7a142be09ea65699e4a6f6ef91c0773c',
  'stores' => 
  array (
    'default_application' => 
    array (
      'name' => 'default_application',
      'plugin' => 'file',
      'configuration' => 
      array (
      ),
      'features' => 30,
      'modes' => 3,
      'default' => true,
      'class' => 'cachestore_file',
      'lock' => 'cachelock_file_default',
    ),
    'default_session' => 
    array (
      'name' => 'default_session',
      'plugin' => 'session',
      'configuration' => 
      array (
      ),
      'features' => 14,
      'modes' => 2,
      'default' => true,
      'class' => 'cachestore_session',
      'lock' => 'cachelock_file_default',
    ),
    'default_request' => 
    array (
      'name' => 'default_request',
      'plugin' => 'static',
      'configuration' => 
      array (
      ),
      'features' => 31,
      'modes' => 4,
      'default' => true,
      'class' => 'cachestore_static',
      'lock' => 'cachelock_file_default',
    ),
    'redis' => 
    array (
      'name' => 'redis',
      'plugin' => 'redis',
      'configuration' => 
      array (
        'server' => '$redisDns',
        'prefix' => 'moodle_prod',
        'password' => '$redisAuth',
        'serializer' => '1',
      ),
      'features' => 26,
      'modes' => 3,
      'mappingsonly' => false,
      'class' => 'cachestore_redis',
      'default' => false,
      'lock' => 'cachelock_file_default',
    ),
    'local_file' => 
    array (
      'name' => 'local_file',
      'plugin' => 'file',
      'configuration' => 
      array (
        'path' => '/tmp/muc/moodle_prod',
        'autocreate' => 1,
      ),
      'features' => 30,
      'modes' => 3,
      'mappingsonly' => false,
      'class' => 'cachestore_file',
      'default' => false,
      'lock' => 'cachelock_file_default',
    ),
  ),
  'modemappings' => 
  array (
    0 => 
    array (
      'store' => 'redis',
      'mode' => 1,
      'sort' => 0,
    ),
    1 => 
    array (
      'store' => 'default_session',
      'mode' => 2,
      'sort' => 0,
    ),
    2 => 
    array (
      'store' => 'default_request',
      'mode' => 4,
      'sort' => 0,
    ),
  ),
  'definitions' => 
  array (
    'core/string' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'string',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/langmenu' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'langmenu',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/databasemeta' => 
    array (
      'mode' => 1,
      'requireidentifiers' => 
      array (
        0 => 'dbfamily',
      ),
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 15,
      'component' => 'core',
      'area' => 'databasemeta',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/eventinvalidation' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'requiredataguarantee' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'eventinvalidation',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/questiondata' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'requiredataguarantee' => false,
      'datasource' => 'question_finder',
      'datasourcefile' => 'question/engine/bank.php',
      'component' => 'core',
      'area' => 'questiondata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/htmlpurifier' => 
    array (
      'mode' => 1,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'htmlpurifier',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/config' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'config',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/groupdata' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'groupdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/calendar_subscriptions' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'calendar_subscriptions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/capabilities' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'capabilities',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/yuimodules' => 
    array (
      'mode' => 1,
      'component' => 'core',
      'area' => 'yuimodules',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/observers' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'observers',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/plugin_manager' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'plugin_manager',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecattree' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'invalidationevents' => 
      array (
        0 => 'changesincoursecat',
      ),
      'component' => 'core',
      'area' => 'coursecattree',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecat' => 
    array (
      'mode' => 2,
      'invalidationevents' => 
      array (
        0 => 'changesincoursecat',
        1 => 'changesincourse',
      ),
      'ttl' => 600,
      'component' => 'core',
      'area' => 'coursecat',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/coursecatrecords' => 
    array (
      'mode' => 4,
      'simplekeys' => true,
      'invalidationevents' => 
      array (
        0 => 'changesincoursecat',
      ),
      'component' => 'core',
      'area' => 'coursecatrecords',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/coursecontacts' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'simplekeys' => true,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'coursecontacts',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/repositories' => 
    array (
      'mode' => 4,
      'component' => 'core',
      'area' => 'repositories',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/externalbadges' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'ttl' => 3600,
      'component' => 'core',
      'area' => 'externalbadges',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursemodinfo' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'canuselocalstore' => true,
      'component' => 'core',
      'area' => 'coursemodinfo',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/userselections' => 
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'userselections',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/completion' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'ttl' => 3600,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'component' => 'core',
      'area' => 'completion',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/coursecompletion' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'ttl' => 3600,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'core',
      'area' => 'coursecompletion',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/navigation_expandcourse' => 
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'navigation_expandcourse',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/suspended_userids' => 
    array (
      'mode' => 4,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'suspended_userids',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/roledefs' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'core',
      'area' => 'roledefs',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/plugin_functions' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 5,
      'component' => 'core',
      'area' => 'plugin_functions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/tags' => 
    array (
      'mode' => 4,
      'simplekeys' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'tags',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/grade_categories' => 
    array (
      'mode' => 2,
      'simplekeys' => true,
      'invalidationevents' => 
      array (
        0 => 'changesingradecategories',
      ),
      'component' => 'core',
      'area' => 'grade_categories',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/temp_tables' => 
    array (
      'mode' => 4,
      'simplekeys' => true,
      'simpledata' => true,
      'component' => 'core',
      'area' => 'temp_tables',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/tagindexbuilder' => 
    array (
      'mode' => 2,
      'simplekeys' => true,
      'simplevalues' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'ttl' => 900,
      'invalidationevents' => 
      array (
        0 => 'resettagindexbuilder',
      ),
      'component' => 'core',
      'area' => 'tagindexbuilder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'core/contextwithinsights' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'core',
      'area' => 'contextwithinsights',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/message_processors_enabled' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 3,
      'component' => 'core',
      'area' => 'message_processors_enabled',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/message_time_last_message_between_users' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simplevalues' => true,
      'datasource' => '\\core_message\\time_last_message_between_users',
      'component' => 'core',
      'area' => 'message_time_last_message_between_users',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/fontawesomeiconmapping' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'core',
      'area' => 'fontawesomeiconmapping',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/postprocessedcss' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => false,
      'component' => 'core',
      'area' => 'postprocessedcss',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'core/user_group_groupings' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'component' => 'core',
      'area' => 'user_group_groupings',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'availability_grade/scores' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'ttl' => 3600,
      'component' => 'availability_grade',
      'area' => 'scores',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'availability_grade/items' => 
    array (
      'mode' => 1,
      'staticacceleration' => true,
      'staticaccelerationsize' => 2,
      'ttl' => 3600,
      'component' => 'availability_grade',
      'area' => 'items',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'mod_glossary/concepts' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => false,
      'staticacceleration' => true,
      'staticaccelerationsize' => 30,
      'component' => 'mod_glossary',
      'area' => 'concepts',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_googledocs/folder' => 
    array (
      'mode' => 1,
      'simplekeys' => false,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'canuselocalstore' => true,
      'component' => 'repository_googledocs',
      'area' => 'folder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_onedrive/folder' => 
    array (
      'mode' => 1,
      'simplekeys' => false,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'canuselocalstore' => true,
      'component' => 'repository_onedrive',
      'area' => 'folder',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'repository_skydrive/foldername' => 
    array (
      'mode' => 2,
      'component' => 'repository_skydrive',
      'area' => 'foldername',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'tool_mobile/plugininfo' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_mobile',
      'area' => 'plugininfo',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_monitor/eventsubscriptions' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 10,
      'component' => 'tool_monitor',
      'area' => 'eventsubscriptions',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_uploadcourse/helper' => 
    array (
      'mode' => 4,
      'component' => 'tool_uploadcourse',
      'area' => 'helper',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 2,
    ),
    'tool_usertours/tourdata' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_usertours',
      'area' => 'tourdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
    'tool_usertours/stepdata' => 
    array (
      'mode' => 1,
      'simplekeys' => true,
      'simpledata' => true,
      'staticacceleration' => true,
      'staticaccelerationsize' => 1,
      'component' => 'tool_usertours',
      'area' => 'stepdata',
      'selectedsharingoption' => 2,
      'userinputsharingkey' => '',
      'sharingoptions' => 15,
    ),
  ),
  'definitionmappings' => 
  array (
    0 => 
    array (
      'store' => 'local_file',
      'definition' => 'core/coursemodinfo',
      'sort' => 1,
    ),
    1 => 
    array (
      'store' => 'redis',
      'definition' => 'core/groupdata',
      'sort' => 1,
    ),
    2 => 
    array (
      'store' => 'redis',
      'definition' => 'core/roledefs',
      'sort' => 1,
    ),
    3 => 
    array (
      'store' => 'redis',
      'definition' => 'tool_usertours/tourdata',
      'sort' => 1,
    ),
    4 => 
    array (
      'store' => 'redis',
      'definition' => 'repository_onedrive/folder',
      'sort' => 1,
    ),
    5 => 
    array (
      'store' => 'redis',
      'definition' => 'core/message_processors_enabled',
      'sort' => 1,
    ),
    6 => 
    array (
      'store' => 'redis',
      'definition' => 'core/coursecontacts',
      'sort' => 1,
    ),
    7 => 
    array (
      'store' => 'redis',
      'definition' => 'repository_googledocs/folder',
      'sort' => 1,
    ),
    8 => 
    array (
      'store' => 'redis',
      'definition' => 'core/questiondata',
      'sort' => 1,
    ),
    9 => 
    array (
      'store' => 'redis',
      'definition' => 'core/coursecat',
      'sort' => 1,
    ),
    10 => 
    array (
      'store' => 'redis',
      'definition' => 'core/databasemeta',
      'sort' => 1,
    ),
    11 => 
    array (
      'store' => 'redis',
      'definition' => 'core/eventinvalidation',
      'sort' => 1,
    ),
    12 => 
    array (
      'store' => 'redis',
      'definition' => 'core/coursecattree',
      'sort' => 1,
    ),
    13 => 
    array (
      'store' => 'redis',
      'definition' => 'core/coursecompletion',
      'sort' => 1,
    ),
    14 => 
    array (
      'store' => 'redis',
      'definition' => 'core/user_group_groupings',
      'sort' => 1,
    ),
    15 => 
    array (
      'store' => 'redis',
      'definition' => 'core/capabilities',
      'sort' => 1,
    ),
    16 => 
    array (
      'store' => 'redis',
      'definition' => 'core/yuimodules',
      'sort' => 1,
    ),
    17 => 
    array (
      'store' => 'redis',
      'definition' => 'core/observers',
      'sort' => 1,
    ),
    18 => 
    array (
      'store' => 'redis',
      'definition' => 'mod_glossary/concepts',
      'sort' => 1,
    ),
    19 => 
    array (
      'store' => 'redis',
      'definition' => 'core/fontawesomeiconmapping',
      'sort' => 1,
    ),
    20 => 
    array (
      'store' => 'redis',
      'definition' => 'core/config',
      'sort' => 1,
    ),
    21 => 
    array (
      'store' => 'redis',
      'definition' => 'tool_mobile/plugininfo',
      'sort' => 1,
    ),
    22 => 
    array (
      'store' => 'redis',
      'definition' => 'core/plugin_functions',
      'sort' => 1,
    ),
    23 => 
    array (
      'store' => 'redis',
      'definition' => 'core/postprocessedcss',
      'sort' => 1,
    ),
    24 => 
    array (
      'store' => 'redis',
      'definition' => 'core/plugin_manager',
      'sort' => 1,
    ),
    25 => 
    array (
      'store' => 'redis',
      'definition' => 'tool_usertours/stepdata',
      'sort' => 1,
    ),
    26 => 
    array (
      'store' => 'redis',
      'definition' => 'availability_grade/items',
      'sort' => 1,
    ),
    27 => 
    array (
      'store' => 'local_file',
      'definition' => 'core/string',
      'sort' => 1,
    ),
    28 => 
    array (
      'store' => 'redis',
      'definition' => 'core/externalbadges',
      'sort' => 1,
    ),
    29 => 
    array (
      'store' => 'local_file',
      'definition' => 'core/langmenu',
      'sort' => 1,
    ),
    30 => 
    array (
      'store' => 'local_file',
      'definition' => 'core/htmlpurifier',
      'sort' => 1,
    ),
    31 => 
    array (
      'store' => 'redis',
      'definition' => 'core/completion',
      'sort' => 1,
    ),
    32 => 
    array (
      'store' => 'redis',
      'definition' => 'core/calendar_subscriptions',
      'sort' => 1,
    ),
    33 => 
    array (
      'store' => 'redis',
      'definition' => 'core/contextwithinsights',
      'sort' => 1,
    ),
    34 => 
    array (
      'store' => 'redis',
      'definition' => 'tool_monitor/eventsubscriptions',
      'sort' => 1,
    ),
    35 => 
    array (
      'store' => 'redis',
      'definition' => 'core/message_time_last_message_between_users',
      'sort' => 1,
    ),
    36 => 
    array (
      'store' => 'redis',
      'definition' => 'availability_grade/scores',
      'sort' => 1,
    ),
  ),
  'locks' => 
  array (
    'cachelock_file_default' => 
    array (
      'name' => 'cachelock_file_default',
      'type' => 'cachelock_file',
      'dir' => 'filelocks',
      'default' => true,
    ),
  ),
);
EOF

    # redis configuration in /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_lock_expire = 7200;" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_acquire_lock_timeout = 120;" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_prefix = 'moodle_prod'; // Optional, default is don't set one." /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_database = 0;  // Optional, default is db 0." /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_port = 6379;  // Optional." /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_host = '$redisDns';" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_redis_auth = '$redisAuth';" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->session_handler_class = '\\\core\\\session\\\redis';" /moodle/html/moodle/config.php

    # We proxy ssl, so moodle needs to know this
    sed -i "23 a \$CFG->sslproxy  = 'true';" /moodle/html/moodle/config.php

    # Set up elasticsearch plugin
    sed -i "23 a \$CFG->forced_plugin_settings = ['search_elastic' => ['hostname' => 'http://$elasticVm1IP']];" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->searchengine = 'elastic';" /moodle/html/moodle/config.php
    sed -i "23 a \$CFG->enableglobalsearch = 'true';" /moodle/html/moodle/config.php

    # Set the ObjectFS alternate filesystem
    sed -i "23 a \$CFG->alternative_file_system_class = '\\\tool_objectfs\\\azure_file_system';" /moodle/html/moodle/config.php

   # Get a new version of Postgres to match Azure version
   add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
   apt-get update
   apt-get install postgresql-client-9.6

   # Set up cronned sql dump
   cat <<EOF > /etc/cron.d/sql-backup
22 02 * * * root /usr/bin/pg_dump -Fc -h $postgresIP -U ${azuremoodledbuser} ${moodledbname} > /moodle/db-backup.sql
EOF


   # Turning off services we don't need the jumpbox running
   service nginx stop
   service php7.0-fpm stop
   service varnish stop
   service varnishncsa stop
   service varnishlog stop

   # make sure Moodle can read its code directory but not write
   sudo chown -R root.root /moodle/html/moodle
   sudo find /moodle/html/moodle -type f -exec chmod 644 '{}' \;
   sudo find /moodle/html/moodle -type d -exec chmod 755 '{}' \;

}  > /tmp/install.log
