# Install Phabricator on a Ubuntu Virtual Machine using Custom Script Linux Extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/phabricator/phabricator-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fphabricator%2Fphabricator-on-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fphabricator%2Fphabricator-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fphabricator%2Fphabricator-on-ubuntu%2Fazuredeploy.json)


This template deploys [Phabricator](http://phabricator.org/) on a Ubuntu Virtual Machine 16.04.0-LTS.

![phabricator img](./images/landing.png)

This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

After the deployment, you should be able to access at phabricator through your DNSNAMEFORPUBLICIP parameter on the port 80 :

![phabricator img](./images/phabricatorHowTo.png)

Next steps for the configuration of phabricator : https://secure.phabricator.com/book/phabricator/article/configuration_guide/ 


