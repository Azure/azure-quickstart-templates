#!/bin/sh
# Custom Minecraft server install script for Ubuntu 15.04
# $1 = Minecraft user name
# $2 = difficulty
# $3 = level-name
# $4 = gamemode
# $5 = white-list
# $6 = enable-command-block
# $7 = spawn-monsters
# $8 = generate-structures
# $9 = level-seed

# add and update repos
while ! echo y | apt-get install -y software-properties-common; do
    sleep 10
    apt-get install -y software-properties-common
done

while ! echo y | apt-add-repository -y ppa:webupd8team/java; do
    sleep 10
    apt-add-repository -y ppa:webupd8team/java
done

while ! echo y | apt-get update; do
    sleep 10
    apt-get update
done

# Install Java8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

while ! echo y | apt-get install -y oracle-java8-installer; do
    sleep 10
    apt-get install -y oracle-java8-installer
done

# create user and install folder
adduser --system --no-create-home --home /srv/minecraft-server minecraft
addgroup --system minecraft
adduser minecraft minecraft
mkdir /srv/minecraft_server
cd /srv/minecraft_server

# download the server jar
while ! echo y | wget https://s3.amazonaws.com/Minecraft.Download/versions/1.8/minecraft_server.1.8.jar; do
    sleep 10
    wget https://s3.amazonaws.com/Minecraft.Download/versions/1.8/minecraft_server.1.8.jar
done

# set permissions on install folder
chown -R minecraft /srv/minecraft_server

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

# create the uela file
touch /srv/minecraft_server/eula.txt
echo 'eula=true' >> /srv/minecraft_server/eula.txt

# create a service
touch /etc/systemd/system/minecraft-server.service
echo '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
echo '[Service]\nWorkingDirectory=/srv/minecraft_server' >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar /srv/minecraft_server/minecraft_server.1.8.jar nogui' $memoryAlloc $memoryAlloc  >> /etc/systemd/system/minecraft-server.service
echo 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
echo '[Install]\nWantedBy=multi-user.target\nAlias=minecraft-server.service' >> /etc/systemd/system/minecraft-server.service

# create and set permissions on user access JSON files
touch /srv/minecraft_server/banned-players.json
chown minecraft:minecraft /srv/minecraft_server/banned-players.json
touch /srv/minecraft_server/banned-ips.json
chown minecraft:minecraft /srv/minecraft_server/banned-ips.json
touch /srv/minecraft_server/whitelist.json
chown minecraft:minecraft /srv/minecraft_server/whitelist.json

# create a valid operators file using the ketrwu.de API
touch /srv/minecraft_server/ops.json
chown minecraft:minecraft /srv/minecraft_server/ops.json
UUID="`wget -q  -O - http://api.ketrwu.de/$1/`"
sh -c "echo '[\n {\n  \"uuid\":\"$UUID\",\n  \"name\":\"$1\",\n  \"level\":4\n }\n]' >> /srv/minecraft_server/ops.json"

# set user preferences in server.properties
touch /srv/minecraft_server/server.properties
chown minecraft:minecraft /srv/minecraft_server/server.properties
# echo 'max-tick-time=-1' >> /srv/minecraft_server/server.properties
sh -c "echo 'difficulty=$2' >> /srv/minecraft_server/server.properties"
sh -c "echo 'level-name=$3' >> /srv/minecraft_server/server.properties"
sh -c "echo 'gamemode=$4' >> /srv/minecraft_server/server.properties"
sh -c "echo 'white-list=$5' >> /srv/minecraft_server/server.properties"
sh -c "echo 'enable-command-block=$6' >> /srv/minecraft_server/server.properties"
sh -c "echo 'spawn-monsters=$7' >> /srv/minecraft_server/server.properties"
sh -c "echo 'generate-structures=$8' >> /srv/minecraft_server/server.properties"
sh -c "echo 'level-seed=$9' >> /srv/minecraft_server/server.properties"

systemctl start minecraft-server
