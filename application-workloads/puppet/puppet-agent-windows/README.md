# Deploy a windows VM with Puppet agent

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/puppet/puppet-agent-windows/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fpuppet%2Fpuppet-agent-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fpuppet%2Fpuppet-agent-windows%2Fazuredeploy.json)

This template provisions a Windows VM on Azure with the Puppet Agent installed using a VM Extension.

The pre-requiste for deploying this template is to having a running Puppet server. You can host your own Puppet server in Azure or on-prem or create a Puppet Server in Azure using the Azure Marketplace image and following the guidelines for [Getting Started Guide for Deploying Puppet Enterprise in Azure](<a href="https://puppet.com/resources/whitepaper/getting-started-deploying-puppet-enterprise-microsoft-azure/" target="_blank">).
