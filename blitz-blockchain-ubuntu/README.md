# Blitz Blockchain Node on Ubuntu VM

This template delivers the Blitz network to your VM in about 20 minutes.  Everything you need to get started using the Blitz blockchain from the command line is included. 
You may build from source.  Once installed, 'blitzd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'blitzd' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblitz-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblitz-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Blitz?

What is Blitz?
----------------

Blitz is a peer-to-peer digital currency with a distributed, decentralized public ledger; that unlike traditional banking systems, are viewable and easily audited by the people.
The ability to manage transactions and issue additional Blitz is all handled by the network of users utilizing Blitz . Because the Blitz network is run by the people, holders of Blitz receive a 10% yearly interest through a process called staking.
Blitz is central blockchain utilized by the Bitalize project, that seeks to build applications on the Blockchain that will increase the adoption of digital currencies.

- 60 second block targets
- Proof of Work/Proof of Stake Hybrid blockchain security model (X13)

Services include:
- Full Blitz Blockchain node.
- P2P communication via the TOR Network

For more information, as well as an immediately useable, binary version of
the Blitz client sofware, see http://bitalize.com/.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Blitz host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Blitz from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch blitzd `sudo blitzd`
* blitzd will run automatically on restart

# Licensing

Blitz is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
