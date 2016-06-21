# Bitswift Blockchain Node on Ubuntu VM

This template delivers the Bitswift network to your VM in about 20 minutes.  Everything you need to get started using the Bitswift blockchain from the command line is included. 
You may build from source.  Once installed, 'bitswiftd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'bitswiftd' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbitswift-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbitswift-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Bitswift?

+ TECHNOLOGY: Proof of Stake
+ SUPPLY: 4 Million 
+ SPEED: 30 seconds
+ INTEREST: 3%

## Distinctive Attributes

One click attach and exist (PoE)
Stealth Addressing
Transaction comment fee structure
Narrations 


## Unique Function

COMPANY:
Bitswift Decentralized Applications (Canada):

* equips your platform with monetization options
* increases your user count
* provides additional revenue options
* expands the options of your platform 
* enhances your users experience 
* allows your platform to be able to prove anything without a doubt 
* provides professional business consulting and integration
* enforces security (no single database to corrupt)
* gives your platform an immediate hook into the blockchain ecosystem
* serves 24/7 support  


Registered business operating out of Canada backing the bitswift blockchain
Canadian Trademark registered on "bitswift" 

For more information, as well as an immediately useable, binary version of
the Bitswift client sofware, see https://bitcointalk.org/index.php?topic=922982.msg10131608#msg10131608.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Bitswift host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Bitswift from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch bitswiftd `sudo bitswiftd`
* `bitswiftd` will run automatically on restart

# Licensing

Bitswift is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
