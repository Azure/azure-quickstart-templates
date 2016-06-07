# Vcash Node on Ubuntu VM

This Microsoft Azure template deploys a Vcash public node that will connect to the main Vcash decentralised network.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvcash-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvcash-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Vcash?
Vcash is a Proof-of-Work and Proof-of-Stake based cryptographic currency which provides a variety of services through blockchain decentralised ledger technology.
Services include:

* Incentivised Node Technology
* Short-Term Data Storage and Retrieval
* Lightweight SQL-like Query Protocol

For more information see: http://www.v.cash/
# Template Parameters
When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Vcash host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.

# Getting Started Tutorial
* Click the `Deploy to Azure` icon.
* Complete the template parameters, choose your resource group, accept the Terms and click Create.
* Wait about 20 minutes for the VM to install the software.
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you need to relaunch vcashd `sudo vcashd`
* The vcashd daemon will  automatically run on system boot