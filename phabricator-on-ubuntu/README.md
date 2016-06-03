# Install Phabricator on a Ubuntu Virtual Machine using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphabricator-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphabricator-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys [Phabricator](http://phabricator.org/) on a Ubuntu Virtual Machine 16.04.0-LTS.

![phabricator img](./images/landing.png)

This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

After the deployment, you should be able to access at phabricator through your DNSNAMEFORPUBLICIP parameter on the port 80 :

![phabricator img](./images/phabricatorHowTo.png)

Next steps for the configuration of phabricator : https://secure.phabricator.com/book/phabricator/article/configuration_guide/ 
