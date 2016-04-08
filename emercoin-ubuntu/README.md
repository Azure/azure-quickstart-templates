# Emercoin Instance

This Microsoft Azure template deploys a single Emercoin client which will connect to the public Emercoin network.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Femercoin-ubuntu%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Femercoin-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Once your deployment is complete you will be able to connect to the Emercoin public network.

![Emercoin-Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/emercoin-ubuntu/images/emercoin.png)

# Template Parameters
When you launch the installation of the VM, you need to specify the following parameters:
* `newStorageAccountNamePrefix`: make sure this is a unique identifier. Azure Storage's accounts are global so make sure you use a prefix that is unique to your account otherwise there is a good change it will clash with names already in use.
* `vmDnsName`: this is the public DNS name for the VM that you will use interact with your console. You just need to specify an unique name.
* `adminUsername`: self-explanatory. This is the account you will use for connecting to the node
* `adminPassword`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number
* `vmSize`: The type of VM that you want to use for the node. The default size is D1 (1 core 3.5GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to

# Emercoin Deployment Walkthrough
1. Get your node's IP
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 3. then expand your resources, and public ip address of your node.

2. Connect to your node
 1. SSH to the public ip of your node as the user you specified for `adminUsername`, enter your `adminPassword`
 2. Try to use the cli-client by `emc help` or `emc getinfo`
 3. Run `emcweb-useradd` and specify credentials for the Emercoin Web Wallet
 4. Point your browser to the public ip of your node, sign in with login and password specified before (note that browser may show you a warning of bad certificate - it's OK, you may replace the self-signed certificates by yours at /etc/ssl/emc/emcweb*). You have check endpoints in openning port 80/tcp and 443/tcp to be accessed to the Emercoin Web Wallet.
