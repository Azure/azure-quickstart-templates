/*
  Get info from deployed ethereum nodes

  To use, install git and npm with the following commands:
  sudo apt-get update
  sudo apt-get install git npm

  Then install web3 with the following command:
  sudo npm install web3

  You can then run the below script with:
  nodejs getnodeinfo.js
*/

var Web3 = require('web3');

for(var i = 0; i <= 4; i++){
	for(var j = 4; j <= 5; j++) {
		var ip = "10.0." + i + "." + j;
		var web3 = new Web3(new Web3.providers.HttpProvider("http://" + ip + ":8545"));

		var peerCount = web3.net.peerCount;
		var blockNumber = web3.eth.blockNumber;

		console.log(ip + ": Peercount " + peerCount + ", Blocknumber " + blockNumber);
	}
}
