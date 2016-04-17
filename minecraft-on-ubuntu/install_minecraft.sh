#!/bin/bash
# Custom Minecraft server install script for Ubuntu 15.04
# $1 = Minecraft user name
# $2 = minecraft Server Version
# $3 = difficulty
# $4 = level-name
# $5 = gamemode
# $6 = white-list
# $7 = enable-command-block
# $8 = spawn-monsters
# $9 = generate-structures
# $10 = level-seed

# basic service and API settings
minecraft_server_path=/srv/minecraft_server
minecraft_user=minecraft
minecraft_group=minecraft
UUID_URL=https://api.mojang.com/users/profiles/minecraft/$1
server_jar=minecraft_server.$2.jar
SERVER_JAR_URL=https://s3.amazonaws.com/Minecraft.Download/versions/$2/minecraft_server.$2.jar

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
adduser --system --no-create-home --home /srv/minecraft-server $minecraft_user
addgroup --system $minecraft_group
mkdir $minecraft_server_path
cd $minecraft_server_path

# download the server jar
while ! echo y | wget $SERVER_JAR_URL; do
    sleep 10
    wget $SERVER_JAR_URL
done

# set permissions on install folder
chown -R $minecraft_user $minecraft_server_path

# adjust memory usage depending on VM size
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 1024 ]; then
    memoryAlloc=512m
else
    memoryAlloc=1024m
fi

# create the uela file
touch $minecraft_server_path/eula.txt
echo 'eula=true' >> $minecraft_server_path/eula.txt

# create a service
touch /etc/systemd/system/minecraft-server.service
printf '[Unit]\nDescription=Minecraft Service\nAfter=rc-local.service\n' >> /etc/systemd/system/minecraft-server.service
printf '[Service]\nWorkingDirectory=%s\n' $minecraft_server_path >> /etc/systemd/system/minecraft-server.service
printf 'ExecStart=/usr/bin/java -Xms%s -Xmx%s -jar %s/%s nogui\n' $memoryAlloc $memoryAlloc $minecraft_server_path $server_jar >> /etc/systemd/system/minecraft-server.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/minecraft-server.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=minecraft-server.service' >> /etc/systemd/system/minecraft-server.service

# create and set permissions on user access JSON files
touch $minecraft_server_path/banned-players.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/banned-players.json
touch $minecraft_server_path/banned-ips.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/banned-ips.json
touch $minecraft_server_path/whitelist.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/whitelist.json

# create a valid operators file using the Mojang API
touch $minecraft_server_path/ops.json
mojang_output="`wget -qO- $UUID_URL`"
rawUUID=${mojang_output:7:32}
UUID=${rawUUID:0:8}-${rawUUID:8:4}-${rawUUID:12:4}-${rawUUID:16:4}-${rawUUID:20:12}
printf '[\n {\n  \"uuid\":\"%s\",\n  \"name\":\"%s\",\n  \"level\":4\n }\n]' $UUID $1 >> $minecraft_server_path/ops.json
chown $minecraft_user:$minecraft_group $minecraft_server_path/ops.json

# set user preferences in server.properties
touch $minecraft_server_path/server.properties
chown $minecraft_user:$minecraft_group $minecraft_server_path/server.properties
# echo 'max-tick-time=-1' >> $minecraft_server_path/server.properties
printf 'difficulty=%s\n' $3 >> $minecraft_server_path/server.properties
printf 'level-name=%s\n' $4 >> $minecraft_server_path/server.properties
printf 'gamemode=%s\n' $5 >> $minecraft_server_path/server.properties
printf 'white-list=%s\n' $6 >> $minecraft_server_path/server.properties
printf 'enable-command-block=%s\n' $7 >> $minecraft_server_path/server.properties
printf 'spawn-monsters=%s\n' $8 >> $minecraft_server_path/server.properties
printf 'generate-structures=%s\n' $9 >> $minecraft_server_path/server.properties
printf 'level-seed=%s\n' ${10} >> $minecraft_server_path/server.properties

systemctl start minecraft-server
