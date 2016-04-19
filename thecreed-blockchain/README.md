# thecreed Blockchain Node on Ubuntu VM

This template delivers the thecreed network to your VM in about 20 minutes.  Everything you need to get started using the thecreed blockchain from the command line is included. 
You may build from source.  Once installed, 'thecreedd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'thecreedd' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fthecreed-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fthecreed-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is thecreed?

What is thecreed?
----------------

Thecreed (TCR)

ALGO: Qubit Block Size: 2 MB Min. Stake Age: 3 Hours Max. Stake Age: Unlimited COINBASE MATURITY: 25 RPCPORT:4665 PORT:4664

PoW: 42 Millions Airdrop Distribution 25.905.000 Millions POW APPROX: 67905000 Max Supply (Pow)

FPoS: 21.024.000 Millions Approx. First 12 Months PoS start block: 172500

BLOCK REWARDS: 0-10: 42.000.000 TCR 10-100: 0 TCR (Anti-Instamine) 100-172800: 150 TCR

For more info: thecreed.tech


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your thecreed host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install thecreed from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch thecreedd `sudo thecreedd`
* thecreedd will run automatically on restart

# Licensing

thecreed is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.

