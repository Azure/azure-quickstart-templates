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
    maharaVersion=${1}
    glusterNode=${2}
    glusterVolume=${3}
    siteFQDN=${4}
    httpsTermination=${5}
    dbIP=${6}
    maharadbname=${7}
    maharadbuser=${8}
    maharadbpass=${9}
    adminpass=${10}
    dbadminlogin=${11}
    dbadminpass=${12}
    wabsacctname=${13}
    wabsacctkey=${14}
    azuremaharadbuser=${15}
    elasticVm1IP=${16}
    dbServerType=${17}
    fileServerType=${18}
    thumbprintSslCert=${19}
    thumbprintCaCert=${20}
    searchType=${21}
    azFQDN=${22}

    echo $maharaVersion        >> /tmp/vars.txt
    echo $glusterNode          >> /tmp/vars.txt
    echo $glusterVolume        >> /tmp/vars.txt
    echo $siteFQDN             >> /tmp/vars.txt
    echo $httpsTermination     >> /tmp/vars.txt
    echo $dbIP                 >> /tmp/vars.txt
    echo $maharadbname         >> /tmp/vars.txt
    echo $maharadbuser         >> /tmp/vars.txt
    echo $maharadbpass         >> /tmp/vars.txt
    echo $adminpass            >> /tmp/vars.txt
    echo $dbadminlogin         >> /tmp/vars.txt
    echo $dbadminpass          >> /tmp/vars.txt
    echo $wabsacctname         >> /tmp/vars.txt
    echo $wabsacctkey          >> /tmp/vars.txt
    echo $azuremaharadbuser    >> /tmp/vars.txt
    echo $elasticVm1IP         >> /tmp/vars.txt
    echo $installElasticSearchSwitch  >> /tmp/vars.txt
    echo $dbServerType                >> /tmp/vars.txt
    echo $fileServerType              >> /tmp/vars.txt
    echo $thumbprintSslCert >> /tmp/vars.txt
    echo $thumbprintCaCert >> /tmp/vars.txt
    echo $searchType >> /tmp/vars.txt
    echo $azFQDN >> /tmp/vars.txt


    . ./helper_functions.sh
    check_fileServerType_param $fileServerType
    configure_site_url ${siteFQDN} ${azFQDN}

    if [ "$dbServerType" = "mysql" ]; then
      mysqlIP=$dbIP
      mysqladminlogin=$dbadminlogin
      mysqladminpass=$dbadminpass

    elif [ "$dbServerType" = "postgres" ]; then
      postgresIP=$dbIP
      pgadminlogin=$dbadminlogin
      pgadminpass=$dbadminpass
    else
      echo "Invalid dbServerType ($dbServerType) given. Only 'mysql' or 'postgres' is allowed. Exiting"
      exit 1
    fi

    # make sure system does automatic updates and fail2ban
    sudo apt-get -y update
    sudo apt-get -y install unattended-upgrades fail2ban pwgen
    config_fail2ban

    # create gluster mount point
    mkdir -p /mahara

    export DEBIAN_FRONTEND=noninteractive

    if [ $fileServerType = "gluster" ]; then
        # configure gluster repository & install gluster client
        sudo add-apt-repository ppa:gluster/glusterfs-3.8 -y                 >> /tmp/apt1.log
    elif [ $fileServerType = "nfs" ]; then
        # configure NFS server and export
        create_filesystem_with_raid /mahara /dev/md1 /dev/md1p1
        configure_nfs_server_and_export /mahara
    fi

    sudo apt-get -y update                                                   >> /tmp/apt2.log
    sudo apt-get -y --force-yes install rsyslog git                          >> /tmp/apt3.log

    if [ $fileServerType = "gluster" ]; then
        sudo apt-get -y --force-yes install glusterfs-client                 >> /tmp/apt3.log
    else # "azurefiles"
        sudo apt-get -y --force-yes install cifs-utils                       >> /tmp/apt3.log
    fi

    if [ $dbServerType = "mysql" ]; then
        sudo apt-get -y --force-yes install mysql-client >> /tmp/apt3.log
    else
        sudo apt-get -y --force-yes install postgresql-client >> /tmp/apt3.log
    fi

    # install azure cli & setup container
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list

    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 >> /tmp/apt4.log
    sudo apt-get -y install apt-transport-https >> /tmp/apt4.log
    sudo apt-get -y update > /dev/null
    sudo apt-get -y install azure-cli >> /tmp/apt4.log

    if [ $fileServerType = "gluster" ]; then
        # mount gluster files system
        echo -e '\n\rInstalling GlusterFS on '$glusterNode':/'$glusterVolume '/mahara\n\r'
        sudo mount -t glusterfs $glusterNode:/$glusterVolume /mahara
    fi

    # install pre-requisites
    sudo apt-get install -y --fix-missing python-software-properties unzip

    # install the entire stack
    sudo apt-get -y  --force-yes install nginx php-fpm varnish >> /tmp/apt5a.log
    sudo apt-get -y  --force-yes install php php-cli php-curl php-zip >> /tmp/apt5b.log

    # Mahara requirements
    sudo apt-get -y update > /dev/null
    sudo apt-get install -y --force-yes graphviz aspell php-common php-soap php-json > /tmp/apt6.log
    sudo apt-get install -y --force-yes php-mbstring php-bcmath php-gd php-mysql php-xmlrpc php-intl php-xml php-bz2 >> /tmp/apt6.log
    sudo apt-get install -y --force-yes npm nodejs-legacy
    if [ $dbServerType = "mysql" ]; then
        sudo apt-get install -y --force-yes php-mysql
    else
        sudo apt-get install -y --force-yes php-pgsql
    fi




    # Set up initial mahara dirs
    mkdir -p /mahara/html/mahara
    mkdir -p /mahara/certs
    mkdir -p /mahara/maharadata
    chown -R www-data.www-data /mahara

    # install Mahara
    echo '#!/bin/bash
    cd /tmp

    # downloading mahara
    /usr/bin/curl -k --max-redirs 10 https://github.com/MaharaProject/mahara/archive/'$maharaVersion'.zip -L -o mahara.zip
    /usr/bin/unzip -q mahara.zip
    # setup theme files
    cd mahara-'$maharaVersion'
    /bin/mv -v * /mahara/html/mahara
    ' > /tmp/setup-mahara.sh

    chmod 755 /tmp/setup-mahara.sh
    sudo -u www-data /tmp/setup-mahara.sh  >> /tmp/setupmahara.log
    cd  /mahara/html/mahara
    npm install -g gulp
    make css


    # create cron entry
    # It is scheduled for once per day. It can be changed as needed.
    echo '* * * * * www-data /usr/bin/php /mahara/html/mahara/htdocs/lib/cron.php 2>&1 | /usr/bin/logger -plocal2.notice -t mahara' > /etc/cron.d/mahara-cron


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

  log_format mahara_combined '\$remote_addr - \$upstream_http_x_maharauser [\$time_local] '
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
        root /mahara/html/mahara/htdocs;
	index index.php index.html index.htm;

        # Log to syslog
        error_log syslog:server=localhost,facility=local1,severity=error,tag=mahara;
        access_log syslog:server=localhost,facility=local1,severity=notice,tag=mahara mahara_combined;

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
        root /mahara/html/mahara/htdocs;
	index index.php index.html index.htm;

        ssl on;
        ssl_certificate /mahara/certs/nginx.crt;
        ssl_certificate_key /mahara/certs/nginx.key;

        # Log to syslog
        error_log syslog:server=localhost,facility=local1,severity=error,tag=mahara;
        access_log syslog:server=localhost,facility=local1,severity=notice,tag=mahara mahara_combined;

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
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /mahara/certs/nginx.key -out /mahara/certs/nginx.crt -subj "/C=BR/ST=SP/L=SaoPaulo/O=IT/CN=$siteFQDN"

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

   # Remove the default site. Mahara is the only site we want
   rm -f /etc/nginx/sites-enabled/default

   # restart Nginx
    sudo service nginx restart

   # Configure varnish startup for 16.04
   VARNISHSTART="ExecStart=\/usr\/sbin\/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f \/etc\/varnish\/mahara.vcl -S \/etc\/varnish\/secret -s malloc,1024m -p thread_pool_min=200 -p thread_pool_max=4000 -p thread_pool_add_delay=2 -p timeout_linger=100 -p timeout_idle=30 -p send_timeout=1800 -p thread_pools=4 -p http_max_hdr=512 -p workspace_backend=512k"
   sed -i "s/^ExecStart.*/${VARNISHSTART}/" /lib/systemd/system/varnish.service

   # Configure varnish VCL for mahara
   cat <<EOF >> /etc/varnish/mahara.vcl
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

    ### Rules for Mahara sites ###
    if (req.url ~ "^/theme/" ||
        req.url ~ "^/js/" ||
        req.url ~ "^/lib/" ||
        req.url ~ "^/libs/"
      ) {
        return(hash);
    }

    # Perform lookup for selected assets that we know are static but Mahara still needs a Cookie
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
    if ( req.url ~ "^/lib/yui/build/mahara-core-checknet/assets/checknet.txt" )
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

    # Almost everything in Mahara correctly serves Cache-Control headers, if
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

    if [ $dbServerType = "mysql" ]; then
        mysql -h $mysqlIP -u $mysqladminlogin -p${mysqladminpass} -e "CREATE DATABASE ${maharadbname} CHARACTER SET utf8;"
        mysql -h $mysqlIP -u $mysqladminlogin -p${mysqladminpass} -e "GRANT ALL ON ${maharadbname}.* TO ${maharadbuser} IDENTIFIED BY '${maharadbpass}';"

        echo "mysql -h $mysqlIP -u $mysqladminlogin -p${mysqladminpass} -e \"CREATE DATABASE ${maharadbname};\"" >> /tmp/debug
        echo "mysql -h $mysqlIP -u $mysqladminlogin -p${mysqladminpass} -e \"GRANT ALL ON ${maharadbname}.* TO ${maharadbuser} IDENTIFIED BY '${maharadbpass}';\"" >> /tmp/debug
    else
        # Create postgres db
        echo "${postgresIP}:5432:postgres:${pgadminlogin}:${pgadminpass}" > /root/.pgpass
        chmod 600 /root/.pgpass
        psql -h $postgresIP -U $pgadminlogin -c "CREATE DATABASE ${maharadbname};" postgres
        psql -h $postgresIP -U $pgadminlogin -c "CREATE USER ${maharadbuser} WITH PASSWORD '${maharadbpass}';" postgres
        psql -h $postgresIP -U $pgadminlogin -c "GRANT ALL ON DATABASE ${maharadbname} TO ${maharadbuser};" postgres
        # Need to preserve pg auth file for updating database later, if elasticsearch option was set.
        if [ $searchType = "none" ]; then
           rm -f /root/.pgpass
        fi
    fi

    # Master config for syslog
    mkdir /var/log/sitelogs
    chown syslog.adm /var/log/sitelogs
    cat <<EOF >> /etc/rsyslog.conf
\$ModLoad imudp
\$UDPServerRun 514
EOF
    cat <<EOF >> /etc/rsyslog.d/40-sitelogs.conf
local1.*   /var/log/sitelogs/mahara/access.log
local1.err   /var/log/sitelogs/mahara/error.log
local2.*   /var/log/sitelogs/mahara/cron.log
EOF
    service rsyslog restart

# Fire off mahara setup
PWGEN=`which pwgen`
SALT=`${PWGEN} 32 1`
URLSECRET=`${PWGEN} 8 1`

    cat <<EOF >> /mahara/html/mahara/htdocs/config.php
<?php
\$cfg = new stdClass();
\$cfg->dbtype   = '$dbServerType';
\$cfg->dbhost   = '$dbIP';
\$cfg->dbport   = null;
\$cfg->dbname   = '$maharadbname';
\$cfg->dbuser   = '$azuremaharadbuser';
\$cfg->dbpass   = '$maharadbpass';
\$cfg->dataroot = '/mahara/maharadata';
\$cfg->wwwroot  = 'https://$siteFQDN';
\$cfg->passwordsaltmain = '$SALT';
\$cfg->productionmode = true;
\$cfg->sslproxy = true;
\$cfg->sendemail = true;
\$cfg->urlsecret = '$URLSECRET';
\$cfg->directorypermissions = 0750;

EOF

cd /tmp; sudo -u www-data /usr/bin/php /mahara/html/mahara/htdocs/admin/cli/install.php --adminpassword="$adminpass" --adminemail=admin@"$siteFQDN" --sitename='Mahara Portfolio' || true

if [ $searchType = "elastic" ]; then
   echo "\$cfg->plugin_search_elasticsearch_indexname = 'mahara';" >> /mahara/html/mahara/htdocs/config.php
   echo "\$cfg->plugin_search_elasticsearch_host = '$elasticVm1IP';" >> /mahara/html/mahara/htdocs/config.php

   if [ $dbServerType = "mysql" ]; then
       mysql -h $mysqlIP -u $mysqladminlogin -p${mysqladminpass}  ${maharadbname} -e "update config set value = 'elasticsearch' where field = 'searchplugin';"

   else
       psql -h $postgresIP -U $pgadminlogin -d ${maharadbname} -c "update config set value = 'elasticsearch' where field = 'searchplugin';" postgres
      rm -f /root/.pgpass
   fi
fi

    echo -e "\n\rDone! Installation completed!\n\r"

   # Set up cronned sql dump
   cat <<EOF > /etc/cron.d/sql-backup
   22 02 * * * root /usr/bin/mysqldump -h $dbIP -u ${azuremaharadbuser} -p'${maharadbpass}' --databases ${maharadbname} | gzip > /mahara/db-backup.sql.gz
EOF

   # Turning off services we don't need the jumpbox running
   service nginx stop
   service php7.0-fpm stop
   service varnish stop
   service varnishncsa stop
   service varnishlog stop

   if [ $fileServerType = "gluster" -o $fileServerType = "nfs" ]; then
      # make sure Mahara can read its code directory but not write
      sudo chown -R root.root /mahara/html/mahara
      sudo find /mahara/html/mahara -type f -exec chmod 644 '{}' \;
      sudo find /mahara/html/mahara -type d -exec chmod 755 '{}' \;
   fi

   if [ $fileServerType = "azurefiles" ]; then
      # Delayed copy of mahara installation to the Azure Files share

      # First rename mahara directory to something else
      mv /mahara /mahara_old_delete_me
      # Then create the mahara share
      echo -e '\n\rCreating an Azure Files share for mahara'
      create_azure_files_mahara_share $wabsacctname $wabsacctkey /tmp/wabs.log
      # Set up and mount Azure Files share. Must be done after nginx is installed because of www-data user/group
      echo -e '\n\rSetting up and mounting Azure Files share on //'$wabsacctname'.file.core.windows.net/mahara on /mahara\n\r'
      setup_and_mount_azure_files_mahara_share $wabsacctname $wabsacctkey
      # Move the local installation over to the Azure Files
      echo -e '\n\rMoving locally installed mahara over to Azure Files'
      cp -a /mahara_old_delete_me/* /mahara || true # Ignore case sensitive directory copy failure
      # rm -rf /mahara_old_delete_me || true # Keep the files just in case
   fi

   create_last_modified_time_update_script
   run_once_last_modified_time_update_script

}  > /tmp/install.log
