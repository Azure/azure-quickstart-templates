
#Modify Sudoers file to not require tty for shell script execution on CentOS
# sudo sed -i '/Defaults[[:space:]]\+requiretty/s/^/#/' /etc/sudoers

# Enable write access to the mongodb.repo and configure it for installation

#sudo chmod 777 /etc/yum.repos.d/mongodb.repo
touch /etc/yum.repos.d/mongodb.repo
echo "[mongodb-org-3.2]" >> /etc/yum.repos.d/mongodb.repo
echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb.repo
echo "baseurl=http://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/" >> /etc/yum.repos.d/mongodb.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" >> /etc/yum.repos.d/mongodb.repo

# Install updates
yum -y update

# Install SELinux management tools and add rule for default port for mongod service
yum install -y policycoreutils-python
semanage port -a -t mongod_port_t -p tcp 27017

# Install Mongo DB and start service
yum install -y mongodb-org
service mongod start
