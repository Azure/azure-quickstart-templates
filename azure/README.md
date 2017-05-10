# Waves Blockchain Node on Ubuntu VM

This template delivers the Waves network to your VM in about 3 minutes.  Everything you need to get started using the Waves blockchain from the command line is included. 
Waves starts automatically in testnet. Please nagivate to `http://publicip:6869` for the api website.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fwavesplatform%2FWaves%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fwavesplatform%2FWaves%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

What is Waves?
----------------
For more information, please visit <a href="https://wavesplatform.com">Waves</a>.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Waves host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Waves from `build.sh`.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 3 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP

# Licensing

Please see <a href="https://github.com/wavesplatform/Waves/blob/master/LICENSE.txt">this</a> for license information.
