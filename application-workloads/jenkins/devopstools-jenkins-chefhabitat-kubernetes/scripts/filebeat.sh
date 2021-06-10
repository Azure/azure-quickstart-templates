!#/bin/bash
sudo wget $1/scripts/filebeat.yml
touch /home/$3/filebeatnew.yml
sudo cat /etc/filebeat/filebeat.yml | sed "s/ \[\"localhost/ \[\"$2/g; s/msadmin/$3/g" >/home/$3/filebeatnew.yml
sudo cp /home/$3/filebeatnew.yml /etc/filebeat/filebeat.yml
sudo service filebeat restart
sudo service filebeat status
