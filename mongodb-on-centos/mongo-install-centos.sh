touch /etc/yum.repos.d/mongodb-org-4.4.repo

echo "[mongodb-org-4.4]" >> /etc/yum.repos.d/mongodb-org-4.4.repo
echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb-org-4.4.repo
echo "baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.4/x86_64/" >> /etc/yum.repos.d/mongodb-org-4.4.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-org-4.4.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb-org-4.4.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc" >> /etc/yum.repos.d/mongodb-org-4.4.repo

yum -y update

yum install -y mongodb-org

service mongod start