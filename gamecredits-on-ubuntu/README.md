# Gamecredits Blockchain Node on Ubuntu VM

This template delivers the Gamecredits network to your VM in about 15 minutes (Installation from binaries).  Everything you need to get started using the Gamecredits blockchain from the command line is included. 
You may select to build from source or install from the binaries.  Once installed, 'gamecreditsd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'gamecreditsd' to interface with the gaming blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fgamecredits-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fgamecredits-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Gamecredits?

[![GameCredits](http://i.imgur.com/aA99Ryn.jpg)](https://www.youtube.com/watch?v=ls8ad6G5ejA)

A new and exciting Open Source Gaming currency that will revolutionize in-game purchases and bring game developers a monetization based on fair-play rules.

GameCredits is a lite version of Bitcoin using scrypt as a proof-of-work algorithm.
 - 1.5 minute block targets
 - subsidy halves in 840k blocks
 - ~84 million total coins
 - 1 blocks to retarget difficulty

For more information, as well as an immediately useable, binary version of
the Gamecredits client sofware, see http://gamecredits.net/.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Gamecredits host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch gamecreditsd `sudo gamecreditsd`
* gamecreditsd will run automatically on restart

# Licensing

Gamecredits is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
