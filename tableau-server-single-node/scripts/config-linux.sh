#!/bin/bash

# confirmed: this script works when run manually as root user from root top directory using the following command
# sh ./config-linux.sh -u <username> -p <password> -h admin -i admin -j 98107 -k usa -l seattle -m data -n tech -o yes -q pm -r 8888888 -s tableau -t wa -v dev -w jamie -x jdata@tableau.com [-y <license key>]
# customized to reflect machine admin username and admin password

while getopts u:p:g:h:i:j:k:l:m:n:o:q:r:s:t:v:w:x:y: option
do
 case "${option}"
 in
 u) USER=${OPTARG};;
 p) PASSWORD=${OPTARG};;
 g) INSTALL_SCRIPT_URL=${OPTARG};;
 h) TS_USER=${OPTARG};;
 i) TS_PASS=${OPTARG};;
 j) ZIP=${OPTARG};;
 k) COUNTRY=${OPTARG};;
 l) CITY=${OPTARG};;
 m) LAST_NAME=${OPTARG};;
 n) INDUSTRY=${OPTARG};;
 o) EULA=${OPTARG};;
 q) TITLE=${OPTARG};;
 r) PHONE=${OPTARG};;
 s) COMPANY=${OPTARG};;
 t) STATE=${OPTARG};;
 v) DEPARMENT=${OPTARG};;
 w) FIRST_NAME=${OPTARG};;
 x) EMAIL=${OPTARG};;
 y) LICENSE_KEY=${OPTARG};;
esac
done

cd /tmp/

# create secrets
echo "tsm_admin_user=\"$USER\"\ntsm_admin_pass=\"$PASSWORD\"\ntableau_server_admin_user=\"$TS_USER\"\ntableau_server_admin_pass=\"$TS_PASS\"" >> secrets

# create registration file
echo "{
 \"zip\" : \"$ZIP\",
 \"country\" : \"$COUNTRY\",
 \"city\" : \"$CITY\",
 \"last_name\" : \"$LAST_NAME\",
 \"industry\" : \"$INDUSTRY\",
 \"eula\" : \"$EULA\",
 \"title\" : \"$TITLE\",
 \"phone\" : \"$PHONE\",
 \"company\" : \"$COMPANY\",
 \"state\" : \"$STATE\",
 \"department\" : \"$DEPARMENT\",
 \"first_name\" : \"$FIRST_NAME\",
 \"email\" : \"$EMAIL\"
}" >> registration.json

# create config file
echo '{
  "configEntities": {
    "identityStore": {
      "_type": "identityStoreType",
      "type": "local"
    }
  }
}' >> config.json
wait

# download tableau server .deb file
# retry on fail
wget --tries=3 --output-document=tableau-installer.deb https://downloads.tableau.com/esdalt/2019.2.1/tableau-server-2019-2-1_amd64.deb

if [ $? -ne 0 ]
then
  echo "wget of Tableau installer failed" >> installer_log.txt
  exit 1;
fi

# download automated-installer
wget --remote-encoding=UTF-8 --output-document=automated-installer.sh $INSTALL_SCRIPT_URL
                                                              
wait
chmod +x automated-installer.sh

echo "modified automated-installer" >> installer_log.txt

# ensure everything is finished
wait

# run automated installer (install trial if no license key)
if [ -z "$LICENSE_KEY" ]
then
      sudo ./automated-installer.sh -s secrets -f config.json -r registration.json -a "$USER" --accepteula tableau-installer.deb --force
else
      sudo ./automated-installer.sh -s secrets -f config.json -r registration.json -a "$USER" -k "$LICENSE_KEY" --accepteula tableau-installer.deb --force
fi

wait

# remove all install files
rm registration.json
rm secrets
rm tableau-installer.deb
rm automated-installer.sh
rm config.json