# Install Phabricator on a Ubuntu Virtual Machine using Custom Script Linux Extension

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/phabricator-on-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphabricator-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphabricator-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys [Phabricator](http://phabricator.org/) on a Ubuntu Virtual Machine 16.04.0-LTS.

![phabricator img](./images/landing.png)

This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

After the deployment, you should be able to access at phabricator through your DNSNAMEFORPUBLICIP parameter on the port 80 :

![phabricator img](./images/phabricatorHowTo.png)

Next steps for the configuration of phabricator : https://secure.phabricator.com/book/phabricator/article/configuration_guide/ 

