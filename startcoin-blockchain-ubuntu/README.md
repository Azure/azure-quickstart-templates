# Startcoin Blockchain Node on Ubuntu VM

This template delivers the Startcoin network to your VM in about 20 minutes.  Everything you need to get started using the Startcoin blockchain from the command line is included. 
You may build from source.  Once installed, 'startcoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'startcoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fstartcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fstartcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Startcoin?

What is Startcoin?
----------------

StartCOIN is a digital currency that rewards you for supporting change. The more you share and support projects, the more StartCOINs you will receive. By joining the StartJOIN community, you become part of this crowd funding revolution. We aim to be the first stable digital currency created to promote and support crowdfunding. StartCOIN is a reward based coin which rewards users for pledging and sharing. It encourages change for good. Register on StartJOIN to be part of a crowdfunding community with a difference, one that harnesses the power of social media to create change.

StartCOIN has been 50% pre-mined, 90% of which will be donated to projects and active users of StartJOIN. There will also be bounties offered for porting existing technologies to StartCOIN.
Mirror: https://bitcointalk.org/index.php?topic=651307.0

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Startcoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Startcoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch startcoind `sudo startcoind`
* startcoind will run automatically on restart

# Licensing

Startcoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
