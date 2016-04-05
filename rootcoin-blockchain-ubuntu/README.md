# Rootcoin Blockchain Node on Ubuntu VM

This template delivers the Rootcoin network to your VM in about 20 minutes.  Everything you need to get started using the Rootcoin blockchain from the command line is included. 
You may build from source.  Once installed, 'rootcoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'rootcoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frootcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frootcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Rootcoin?

What is Rootcoin?
----------------

Rootcoin is a digital currency (cryptocurrency) based on bitcoin. It is a pure PoS currency means it generates block by staking rewards on decentralized nodes. The Proof-of-Work stage already ended in 2014. Rootcoin has a small but active community and developer-team behind it. If you have question send a PM to the official rootcoin-team-account on bitcointalk to join our community-slack.

Mirror: https://bitcointalk.org/index.php?topic=911742.0

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Rootcoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Rootcoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.
* `rpcuser`: This is the username for connectiong to the daemon via RPC.
* `rpcpass`: This is the password for connectiong to the daemon via RPC.
* `rpcport`: This is the port for connectiong to the daemon via RPC.
* `allowip`: This is the ip address to allow to access daemon via RPC.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch rootcoind `sudo rootcoind`
* rootcoind will run automatically on restart

# Licensing

Rootcoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
