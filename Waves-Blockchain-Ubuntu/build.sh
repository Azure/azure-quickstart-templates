#!/bin/bash
wget https://github.com/wavesplatform/Waves/releases/download/v0.1.3/waves-testnet-0.1.3.zip
sudo apt-get update
sudo apt-get install -y software-properties-common unzip
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y --force-yes oracle-java8-installer
unzip waves-testnet-0.1.3.zip
mv waves-testnet-0.1.3 waves
cd waves
sudo dpkg -i waves_0.1.3_all.deb
rm waves-testnet.json
echo "{
  "p2p": {
    "bindAddress": "0.0.0.0",
    "upnp": false,
    "upnpGatewayTimeout": 7000,
    "upnpDiscoverTimeout": 3000,
    "port": 6868,
    "knownPeers": ["52.58.115.4:6868","52.36.177.184:6868"],
    "maxConnections": 10
  },
  "walletDir": "/tmp/scorex/waves/wallet",
  "walletSeed": "testing1234",
  "walletPassword": "tester",
  "dataDir": "/tmp/scorex/waves/data",
  "rpcPort": 6869,
  "rpcAllowed": [],
  "blockGenerationDelay": 1000,
  "cors": true,
  "maxRollback": 100,
  "history": "blockchain",
  "offlineGeneration": false
}" >> waves-testnet.json
echo
echo
waves waves-testnet.json
