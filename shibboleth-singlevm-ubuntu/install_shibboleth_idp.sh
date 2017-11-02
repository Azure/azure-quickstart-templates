domain=$1
location=$2
SITENAME=$1.$2.cloudapp.azure.com

INSTALLDIR=/opt/shibboleth-idp

apt-get -y update

echo "==============>Printing values of all variables"
echo "domain"
echo $domain
echo "location"
echo $location
echo "Sitename"
echo $SITENAME
