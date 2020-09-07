# Create file mongodb.repo and configure it for installation
touch /etc/yum.repos.d/mongodb.repo
echo "[mongodb-org-4.4]" >> /etc/yum.repos.d/mongodb.repo
echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb.repo
echo "baseurl=http://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.4/x86_64/" >> /etc/yum.repos.d/mongodb.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc" >> /etc/yum.repos.d/mongodb.repo

# Install updates
yum -y update

# Install Mongo DB and start service
yum install -y mongodb-org
systemctl start mongod.service
systemctl enable mongod.service