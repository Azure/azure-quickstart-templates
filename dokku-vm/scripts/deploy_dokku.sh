# installs dokku via apt-get
DOKKU_VERSION=$1
wget https://raw.githubusercontent.com/dokku/dokku/v${DOKKU_VERSION}/bootstrap.sh
sudo DOKKU_TAG=v${DOKKU_VERSION} bash bootstrap.sh
