#Private Augur Instance on Ubuntu

This Microsoft Azure template deploys a single Ethereum client with a private chain, and the Augur contracts and UI.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Faugur-on-ubuntu%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Faugur-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Once your deployment is complete you will have a private Augur instance with:

1)Geth running, with mining turning on/off when transactions appear to save resources.

2)The Augur contracts installed to your private chain.

3)A publicly accessible UI.

** Note this private key is exposed on a public GitHub repository. It should _never_ be used on a public network. If you use this key for anything besides your private Augur instance, your funds will be lost!

![Augur-Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/augur-on-ubuntu/images/augur_logo.png)

# Template Parameters
When you launch the installation, you need to specify the following parameters:
* `newStorageAccountNamePrefix`: make sure this is a unique identifier. Azure Storage's accounts are global so make sure you use a prefix that is unique to your account otherwise there is a good change it will clash with names already in use.
* `vmDnsPrefix`: this is the public DNS name for the VM that you will use interact with your augur instance. You just need to specify an unique name.
* `adminUsername`: self-explanatory. This is the account you will use for connecting to the node
* `adminPassword`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number
* `vmSize`: The type of VM that you want to use for the node. The default size is Standard_A1 (1 core .75GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to


# Interacting with your Augur instance
Your Augur UI will be available at the url http://vmDnsPrefix.location.cloudapp.azure.com, where vmDnsPrefix and location are the parameter you entered into the template during deployment.

If needed, you may also SSH into your VM at `adminUsername@vmDnsPrefix.location.cloudapp.azure.com`.

Both geth and the augur_ui run as a service that starts on system startup. If you need to stop these for some reason, you can do:

```
sudo start/stop geth
sudo start/stop augur_ui
```

#Security/Privacy
By default your Augur instance is publicly available without restriction, assuming they know its URL. If you'd prefer to restrict access to an ip/ip range, this can be done by modifying the Network Security Group in the Azure Portal.

Your VM will also be left with geth's RPC server available, and an unlocked account that contains all of your private chain's ether. Without further access restriction, it is trivial for anyone who knows your RPC server's address to drain your account of private ether.

#Updates
Augur is in Beta and undergoing rapid development. Not all features of the UI are guaranteed to work. To update to the latest UI at any point, ssh into your VM and run this as your adminUser (not root).
```
curl -sL https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/augur-on-ubuntu/update-augur.sh | bash
```


