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
    mariadbIP=$5
    moodledbname=$6
    moodledbuser=$7
    moodledbpass=$8
       adminpass=$9

	echo $moodleVersion  >> /tmp/vars.txt
	echo $glusterNode    >> /tmp/vars.txt
	echo $glusterVolume  >> /tmp/vars.txt
	echo $siteFQDN       >> /tmp/vars.txt
	echo $mariadbIP      >> /tmp/vars.txt
	echo $moodledbname   >> /tmp/vars.txt
	echo $moodledbuser   >> /tmp/vars.txt
	echo $moodledbpass   >> /tmp/vars.txt
	echo    $adminpass   >> /tmp/vars.txt

    # create gluster mount point
    mkdir -p /moodle

    #configure gluster repository & install gluster client
    sudo add-apt-repository ppa:gluster/glusterfs-3.8 -y                     >> /tmp/apt1.log
    sudo apt-get -y update                                                   >> /tmp/apt2.log
    sudo apt-get -y --force-yes install glusterfs-client mysql-client git    >> /tmp/apt3.log



    # mount gluster files system
    echo -e '\n\rInstalling GlusterFS on '$glusterNode':/'$glusterVolume '/moodle\n\r' 
    sudo mount -t glusterfs $glusterNode:/$glusterVolume /moodle

    #create html directory for storing moodle files
    sudo mkdir -p /moodle/html

    # create directory for apache ssl certs
    sudo mkdir -p /moodle/certs

    # create moodledata directory
    sudo mkdir -p /moodle/moodledata

     # configuring PHP 5.6 repository (NEW LINES TO ADD BEFORE THE �Install Lamp Stack� BELLOW) 
    sudo add-apt-repository -y ppa:ondrej/php                                >> /tmp/apt4.log
    sudo apt-get -y update                                                   >> /tmp/apt4.log

    # install pre-requisites
    sudo apt-get install -y --fix-missing python-software-properties unzip

    # install the LAMP stack
    sudo apt-get -y  --force-yes install apache2                             >> /tmp/apt5a.log
    sudo apt-get -y  --force-yes install php5.6 php5.6-cli php5.6-curl php5.6-zip >> /tmp/apt5b.log

    # install moodle requirements
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    sudo add-apt-repository 'deb http://mirror.edatel.net.co/mariadb/repo/10.1/ubuntu trusty main'

    sudo apt-get -y update > /dev/null
    sudo apt-get install -y --force-yes mariadb-client 
    sudo apt-get install -y --force-yes graphviz aspell php5.6-common php5.6-soap php5.6-json php5.6-zip         > /tmp/apt6.log
    sudo apt-get install -y --force-yes php5.6-bcmath php5.6-gd php5.6-mysql php5.6-xmlrpc php5.6-intl php5.6-xml php5.6-bz2 >> /tmp/apt6.log
    sudo apt-get install -y --force-yes php5.6-redis php5.6-curl php5.6-mysql >> /tmp/apt6.log

    # install Moodle 
    echo '#!/bin/bash
    cd /tmp

    # downloading moodle 
    curl -k --max-redirs 10 https://github.com/moodle/moodle/archive/'$moodleVersion'.zip -L -o moodle.zip
    unzip -q moodle.zip
    echo -e \n\rMoving moodle files to Gluster\n\r 
    mv -v moodle-'$moodleVersion' /moodle/html/moodle

    # install Office 365 plugins
    #if [ "$installOfficePlugins" = "True" ]; then
            curl -k --max-redirs 10 https://github.com/Microsoft/o365-moodle/archive/'$moodleVersion'.zip -L -o o365.zip
            unzip -q o365.zip
            cp -r o365-moodle-'$moodleVersion'/* /moodle/html/moodle
            rm -rf o365-moodle-'$moodleVersion'
    #fi
    ' > /tmp/setup-moodle.sh 
    sudo chmod +x /tmp/setup-moodle.sh
    sudo /tmp/setup-moodle.sh                  >> /tmp/apt7.log

    # create cron entry
    # It is scheduled for once per day. It can be changed as needed.
    echo '0 0 * * * php /moodle/html/moodle/admin/cli/cron.php > /dev/null 2>&1' > cronjob
    sudo crontab cronjob

    # update Apache configuration
    sudo cp /etc/apache2/apache2.conf apache2.conf.bak
    sudo sed -i 's/\/var\/www/\/\moodle/g' /etc/apache2/apache2.conf
    sudo echo ServerName \"localhost\"  >> /etc/apache2/apache2.conf

    #enable ssl 
    a2enmod rewrite ssl

    echo -e "Generating SSL self-signed certificate"
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /moodle/certs/apache.key -out /moodle/certs/apache.crt -subj "/C=BR/ST=SP/L=SaoPaulo/O=IT/CN=$siteFQDN"

    echo -e "\n\rUpdating PHP and site configuration\n\r" 
    #update virtual site configuration 
    echo -e '
    <VirtualHost *:80>
            #ServerName www.example.com
            ServerAdmin webmaster@localhost
            DocumentRoot /moodle/html/moodle
            #LogLevel info ssl:warn
            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined
            #Include conf-available/serve-cgi-bin.conf
    </VirtualHost>
    <VirtualHost *:443>
            DocumentRoot /moodle/html/moodle
            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined

            SSLEngine on
            SSLCertificateFile /moodle/certs/apache.crt
            SSLCertificateKeyFile /moodle/certs/apache.key
            BrowserMatch "MSIE [2-6]" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
            BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown        

    </VirtualHost>' > /etc/apache2/sites-enabled/000-default.conf

   # php config 
   PhpIni=/etc/php5/apache2/php.ini
   sed -i "s/memory_limit.*/memory_limit = 512M/" $PhpIni
   sed -i "s/;opcache.use_cwd.*/opcache.use_cwd = 1/" $PhpIni
   sed -i "s/;opcache.validate_timestamps.*/opcache.validate_timestamps = 1/" $PhpIni
   sed -i "s/;opcache.save_comments.*/opcache.save_comments = 1/" $PhpIni
   sed -i "s/;opcache.enable_file_override.*/opcache.enable_file_override = 0/" $PhpIni
   sed -i "s/;opcache.enable.*/opcache.enable = 1/" $PhpIni
   sed -i "s/;opcache.memory_consumption.*/opcache.memory_consumption = 256/" $PhpIni
   sed -i "s/;opcache.max_accelerated_files.*/opcache.max_accelerated_files = 8000/" $PhpIni
    
    sudo chown -R www-data /moodle/html/moodle
    sudo chown -R www-data /moodle/certs
    sudo chown -R www-data /moodle/moodledata
    sudo chmod -R 770 /moodle/html/moodle
    sudo chmod -R 770 /moodle/certs
    sudo chmod -R 770 /moodle/moodledata



   # restart Apache
    echo -e "\n\rRestarting Apache2 httpd server\n\r"
    sudo service apache2 restart 
    
    echo -e "sudo -u www-data /usr/bin/php /moodle/html/moodle/admin/cli/install.php --chmod=770 --lang=pt_br --wwwroot=https://"$siteFQDN" --dataroot=/moodle/moodledata --dbhost="$mariadbIP" --dbname="$moodledbname" --dbuser="$moodledbuser" --dbpass="$moodledbpass" --dbtype=mariadb --fullname='Moodle LMS' --shortname='Moodle' --adminuser=admin --adminpass="$adminpass" --adminemail=admin@"$siteFQDN" --non-interactive --agree-license --allow-unstable || true "
	         sudo -u www-data /usr/bin/php /moodle/html/moodle/admin/cli/install.php --chmod=770 --lang=en_us --wwwroot=https://$siteFQDN   --dataroot=/moodle/moodledata --dbhost=$mariadbIP   --dbname=$moodledbname   --dbuser=$moodledbuser   --dbpass=$moodledbpass   --dbtype=mariadb --fullname='Moodle LMS' --shortname='Moodle' --adminuser=admin --adminpass=$adminpass   --adminemail=admin@$siteFQDN   --non-interactive --agree-license --allow-unstable || true

    echo -e "\n\rDone! Installation completed!\n\r"
}  > /tmp/install.log
