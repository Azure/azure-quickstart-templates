# Jumbucks Blockchain Node on Ubuntu VM

This template delivers the Jumbucks network to your VM in about 20 minutes.  Everything you need to get started using the Jumbucks blockchain from the command line is included. 
You may build from source.  Once installed, 'jumbucksd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'jumbucksd' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fjumbucks-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fjumbucks-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Jumbucks?

What is Jumbucks?
----------------

Jumbucks is a Proof of Work/Proof of Stake scrypt coin which provides an array of useful services
which leverage the bitcoin protocol and blockchain technology.

 - 1 minute block targets
 - Proof of Work/Proof of Stake blockchain security model (scrypt)

For more information, as well as an immediately useable, binary version of
the Jumbucks client sofware, see http://www.getjumbucks.com.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Jumbucks host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Jumbucks from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch jumbucksd `sudo jumbucksd`
* jumbucksd will run automatically on restart

# Licensing

Jumbucks is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
