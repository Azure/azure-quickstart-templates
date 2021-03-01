# Custom Script for Linu#commands for installing mongo db:

#Step 1 - Importing the Public Key
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

#Step 2 - Create source list file MongoDB:
echo "deb http://repo.mongodb.org/apt/ubuntu "xenial"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

#Step 3 - Update the repository
apt-get update

#Step 4 - Install MongoDB
apt-get install -y mongodb-org

#Start mongodb and add it as service to be started at boot time:
systemctl start mongod
systemctl enable mongod

#Install Nodejs
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

#Clone todo app
mkdir /app
git clone $1 /app

#Install Nodejs app
cd /app
npm install
#App to be started manually by user post declaing MONGODB_URL var
#export MONGODB_URL="mongodb://localhost/tododb"
#nom start
exit 0
