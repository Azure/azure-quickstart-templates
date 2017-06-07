#!/bin/bash
sudo su
#export RAILS_ENV=production
#sudo asctl faspex:rake --trace entitlement:config_license_server EL_KEY="638d51b2-23fb-4b2a-bb31-d91d5b0b55af " EL_CUSTOMER_ID="89280462-5bf1-4371-95cc-ab4cb2f33a5e "
sudo useradd -r faspex
sudo useradd -r faspex -s /bin/aspshell -r -g faspex
sudo mkdir -p /home/faspex/faspex_packages
sudo chown faspex:faspex /home/faspex/
sudo chown faspex:faspex /home/faspex/faspex_packages 
#sudo echo hostname >> /opt/aspera/etc/aspera.conf
sudo service asperacentral restart
sudo service asperanoded restart
sudo /opt/aspera/bin/asuserdata -v
sudo /opt/aspera/bin/asnodeadmin -a -u nodeuser -p nodepasswd -x sysgain --acl-set impersonation
sudo /opt/aspera/bin/asnodeadmin -l
sudo mkdir -p /home/faspex/.ssh
sudo cat /opt/aspera/var/aspera_id_dsa.pub >> /home/faspex/.ssh/authorized_keys
sudo chown faspex:faspex /home/faspex/.ssh  
sudo chown faspex:faspex /home/faspex/.ssh/authorized_keys
sudo chmod 600 /home/faspex/.ssh/authorized_keys
sudo chmod 700 /home/faspex
sudo chmod 700 /home/faspex/.ssh
#asctl apache:make_ssl_cert HOSTNAME
