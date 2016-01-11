# installs dokku via apt-get
DOKKU_VERSION=$1
wget https://raw.githubusercontent.com/progrium/dokku/v${DOKKU_VERSION}/bootstrap.sh
sudo DOKKU_TAG=v0.4.4 bash bootstrap.sh
