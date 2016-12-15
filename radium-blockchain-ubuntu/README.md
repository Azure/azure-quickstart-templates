# Radium Blockchain Node on Ubuntu VM
This template delivers the Radium network to your VM.  Everything you need to get started using the Radium blockchain can be deployed right from the Azure console. No commandline is necessary, standard RPC connection settings can be set during deployment in the Azure portal. This template builds from source.  Once installed, 'Radiumd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM, or simply connect directly via RPC using the custom RPC values set during deployment.
                                                                         
<a href=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmaster%2fradium-blockchain-ubuntu%2fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fradium-blockchain-ubuntu%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# What is Radium?

Radium is a Proof-Of-Stake Cryptocurrency that serves as the base blockchain for the Radium SmartChain.
 - 1 minute block targets
 - Proof-Of-Stake
 
Services include:

- Username - Address linking
- Identity Verification
- Proof of Existence: Text Notes
- Proof of Existence: File Hashing + Verification
- Radium Send
- Radon Asset Transfer
- Abuse Prevention
- For more information see http://www.projectradon.info or https://bitcointalk.org/index.php?topic=1333026.0

# Template Parameters

When you click the `Deploy to Azure` icon above, you need to specify the following template parameters:
* `adminUsername`: This is the account for connecting to your Radium host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  This installs from source, but be advised this may take a long time to complete.
* `vmSize`: This is the size of the VM to use. It is by default set to A2.
* `rpcuser`: This is the username for connectiong to the daemon via RPC.
* `rpcpass`: This is the password for connectiong to the daemon via RPC.
* `rpcport`: This is the port for connectiong to the daemon via RPC.
* `allowip`: This is the ip address to allow to access daemon via RPC.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above.
* Complete the template parameters, choose your resource group, accept the terms and click Create.
* Wait about 1 hour for the VM to spin up and install the software. In the future with a PPA or .deb this should take significantly less time.
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* Radiumd will run automatically

# Licensing

Radium is released under the terms of the MIT license. See http://opensource.org/licenses/MIT for more information.
