#!/bin/bash

VERSION=$1
RELEASE=$2
PASSWORD=$3

# Install Java JDK
echo "Installing Java JDK"

#zypper search java | grep openjdk
zypper --non-interactive install java-1_7_0-openjdk

# Retrieve Glassfish source files
echo "Retrieving Glassfish source files"

wget http://download.java.net/glassfish/3.1.2.2/release/glassfish-$RELEASE.zip -P /tmp/
unzip /tmp/glassfish-$RELEASE.zip -d /opt
rm /tmp/glassfish-$RELEASE.zip

# Start GlassFish Server
echo "Starting GlassFish server"

/opt/glassfish$VERSION/bin/asadmin start-domain

# Enable admin access
echo "Enabling admin Access"

touch /tmp/password.txt
chmod 600 /tmp/password.txt
echo "AS_ADMIN_PASSWORD=" > /tmp/password.txt
echo "AS_ADMIN_NEWPASSWORD=$PASSWORD" >> /tmp/password.txt
/opt/glassfish$VERSION/bin/asadmin --user admin --passwordfile /tmp/password.txt change-admin-password \
    --domain_name domain1
sed -i '/^AS_ADMIN_PASSWORD=/d' /tmp/password.txt
sed -i '/^AS_ADMIN_NEW_PASSWORD=/d' /tmp/password.txt
echo "AS_ADMIN_PASSWORD=$PASSWORD" > /tmp/password.txt
/opt/glassfish$VERSION/bin/asadmin --user admin --passwordfile /tmp/password.txt enable-secure-admin
rm /tmp/password.txt

# Enable GlassFish as a service and quick initialization
echo "Enabling GlassFish as a service"
tee /etc/init.d/glassfish > /dev/null <<'EOF'

# Set path variable
GLASSFISH_HOME=/opt/glassfish$VERSION

# Establish service commands
case "$1" in
start)
    ${GLASSFISH_HOME}/bin/asadmin start-domain domain1
    ;;
stop)
    ${GLASSFISH_HOME}/bin/asadmin stop-domain domain1
    ;;
restart)
    ${GLASSFISH_HOME}/bin/asadmin stop-domain domain1
    ${GLASSFISH_HOME}/bin/asadmin start-domain domain1
    ;;
*)
    echo "usage: $0 {start|stop|restart}"
    ;;
esac
exit 0

EOF

chmod 755 /etc/init.d/glassfish

echo "Script complete"
