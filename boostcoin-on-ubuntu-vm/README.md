# BoostCoin-core Blockchain Node on Ubuntu VM

This template delivers the BoostCoin-core daemon client to your VM in about 15 minutes. Everything you need to get started using the BoostCoin-core blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, 'boostcoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'boostcoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fboostcoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fboostcoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is BoostCoin-core?

What is BoostCoin-core?
----------------

BoostCoin-core is a hybrid Proof of Work / Proof of Stake Crypto currency which is based on the bitcoin protocol
and blockchain technology


 - Proof of Stake rewards
 - 2 minute block targets
 - Utilises a built in Tor proxy 



For more information, see http://www.bost.link.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your BoostCoin-core host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch boostcoind `sudo ./boostcoind`
* boostcoind will run automatically on restart

# Licensing

BoostCoin-core is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.