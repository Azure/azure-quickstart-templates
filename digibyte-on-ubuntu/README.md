# DigiByte Blockchain Node on Ubuntu VM

This template delivers the DigiByte network to your VM in about 15 minutes (PPA install).  Everything you need to get started using the DigiByte blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, 'digibyted' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'digibyted' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdigibyte-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdigibyte-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is DigiByte?

What is DigiByte?
----------------

DigiByte is an experimental new digital currency that enables instant payments to anyone, anywhere in the world. DigiByte uses peer-to-peer technology to operate with no central authority: managing transactions and issuing money are carried out collectively by the network. DigiByte Core is the name of open source software which enables the use of this currency.


Technical Specifications
---------------------

 - MultiAlgo POW (Scrypt, SHA256D, Qubit, Skein and Groestl) algorithms
 - 30 Second block Target (2.5 min per Algo)
 - ~21 billion total coins
 - 8000 coins per block, reduces by 0.5% every 10,080 blocks starting 2/28/14
 - Difficulty retarget every 1 block (2.5 Min) Averaged over previous 10 blocks per algo

Services include:

- Data storage
- Digital document storage, ownership & exchange
- Digital Certificates

Links
------------------------
Website: http://www.digibyte.co

DigiByteTalk: http://digibytetalk.com/index.php

BitcoinTalk: https://bitcointalk.org/index.php?topic=408268.0

Facebook: https://www.facebook.com/digibytecoin

Twitter: https://twitter.com/digibytecoin

VK: https://vk.com/digibyte

Reddit: http://www.reddit.com/r/Digibyte/

IRC Channel: http://webchat.freenode.net/?channels=#digibytecoin


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your DigiByte host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch digibyted `sudo digibyted`
* digibyted will run automatically on restart

# Licensing

DigiByte is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.