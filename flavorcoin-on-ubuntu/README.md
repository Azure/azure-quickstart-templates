# FlavorCoin Blockchain Node on Ubuntu VM

This template delivers the FlavorCoin network to your VM in about 20 minutes.  Everything you need to get started using the FlavorCoin blockchain from the command line is included. 
You may build from source.  Once installed, 'FlavorCoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'FlavorCoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fflavorcoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fflavorcoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is FlavorCoin?

What is FlavorCoin?
----------------

FlavorCoin is pure Proof of Stake coin, except stage of initial distribution, when it was offered as ICO.
For more info see: https://altcoinflavorcoin.com

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your FlavorCoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install FlavorCoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch FlavorCoind `sudo FlavorCoind`
* FlavorCoind will run automatically on restart

# Licensing

FlavorCoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
