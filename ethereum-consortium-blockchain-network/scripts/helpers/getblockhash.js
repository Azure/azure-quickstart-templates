/*
  Get block hashes from deployed ethereum nodes
  Use this to verify that nodes are syncing correctly: block hashes should match

  To use, install git and npm with the following commands:
  sudo apt-get update
  sudo apt-get -y install git npm

  Then install web3 with the following command:
  sudo npm install web3

  You can then run the below script with:
  nodejs getblockhash.js <blocknum>

  Example:
  nodejs getblockhash.js 30
*/

var Web3 = require('web3');

for(var i = 0; i <= 4; i++){
        for(var j = 4; j <= 5; j++) {
                var ip = "10.0." + i + "." + j;
                var web3 = new Web3(new Web3.providers.HttpProvider("http://" + ip + ":8545"));

                var blockHash = web3.eth.getBlock(process.argv[2]).hash;

                console.log(ip + ": Blockhash " + blockHash);
        }
}
