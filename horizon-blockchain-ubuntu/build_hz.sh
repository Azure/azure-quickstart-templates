#!/bin/bash
sudo apt-get update
sudo apt-get install -y software-properties-common unzip
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y --force-yes oracle-java8-installer
cd /usr/local
sudo wget https://github.com/NeXTHorizon/hz-source/releases/download/hz-v5.4/hz-v5.4-node.zip
sudo unzip hz-v5.4-node.zip
#echo "#!/bin/bash sudo nohup ./usr/local/hz-v5.4-node/run.sh &" | sudo tee /etc/init.d/Horizon
cd /usr/local/hz-v5.4-node/
sudo nohup ./run.sh &
echo "Horizon has been setup successfully and is running..."
echo 
echo
echo
exit 0
