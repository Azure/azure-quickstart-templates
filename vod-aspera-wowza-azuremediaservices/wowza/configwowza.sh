#!/bin/bash
#arguments: username, storage account, storage access key, container name
#Install azure CLI for storage 
sudo su
cd /home/$1
sudo apt-get update
sudo apt-get install -y npm
wget http://aka.ms/linux-azure-cli
sudo npm install -g linux-azure-cli
sudo ln -s /usr/bin/nodejs /usr/bin/node
azure telemetry --disable

export USER=$1
export AZURE_STORAGE_ACCOUNT=$2
export AZURE_STORAGE_ACCESS_KEY=$3
export CONTAINER_NAME=$4
export DESTINATION_FOLDER=/usr/local/WowzaStreamingEngine/content/
export EDITOR=vi 

echo "export AZURE_STORAGE_ACCOUNT="$2 >>.profile
echo "export AZURE_STORAGE_ACCESS_KEY="$3 >>.profile



sudo chmod 777 /usr/local/WowzaStreamingEngine/content/
touch /tmp/videos
chmod 777 /tmp/videos
echo "export AZURE_STORAGE_ACCOUNT="$2 >>pollsa.sh
echo "export AZURE_STORAGE_ACCESS_KEY="$3 >>pollsa.sh
wget https://raw.githubusercontent.com/sysgain/wowzaP2P/master/wowza/scripts/command
cat command >>pollsa.sh
sudo chmod 777 pollsa.sh

echo "#!/bin/bash" >>download1.sh
echo "export AZURE_STORAGE_ACCOUNT="$2 >>download1.sh
echo "export AZURE_STORAGE_ACCESS_KEY="$3 >>download1.sh
echo '/bin/sh ~/pollsa.sh' >>download1.sh
echo 'i=`cat /tmp/videos | wc -l`' >>download1.sh
echo "l=1" >> download1.sh
echo 'for j in $(seq $i)' >>download1.sh
echo 'do' >> download1.sh
echo 'k=`cat /tmp/videos | head -n $j | tail -n $l`' >> download1.sh
echo '/usr/local/bin/azure storage blob download -q videos "$k" /usr/local/WowzaStreamingEngine/content/"$k"' >>download1.sh
echo 'done' >>download1.sh
echo 'sleep 10' >>download1.sh
echo 'for j in $(seq $i)' >>download1.sh
echo 'do' >>download1.sh
echo 'k=`cat /tmp/videos | head -n $j | tail -n $l`' >>download1.sh
echo '/usr/local/bin/azure storage blob delete -q videos $k' >>download1.sh
echo 'done' >>download1.sh
sudo chmod 777 download1.sh

sudo chmod 777 download1.sh

echo "*/5 * * * * sh /home/"$USER"/download1.sh > /home/"$USER"/backup.log 2>&1" >> mycron.txt
sudo chmod 777 mycron.txt
crontab -l -u $USER | cat - mycron.txt| crontab -u $USER -
sleep 5
/etc/init.d/cron restart

#configure admin password
cd /usr/local/WowzaStreamingEngine/conf
sudo chmod 777 admin.password
echo "wowza  Ignite@2016  admin" > admin.password
#configure stream publish password
sudo chmod 777 publish.password
echo "wowza Ignite@2016" > publish.password
