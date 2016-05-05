# Deploy a windows VM with Puppet agent.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-agent-windows%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-agent-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template provisions a Windows VM on Azure with the Puppet Agent installed using a VM Extension.

The pre-requiste for deploying this template is to having a running Puppet server. You can host your own Puppet server in Azure or on-prem or create a Puppet Server in Azure using the Azure Marketplace image and following the guidelines for: <a href="https://puppetlabs.com/sites/default/files/Microsoft-Powershell-cmdlets.pdf" target="_blank">Getting Started Guide for Deploying Puppet Enterprise in Azure</a>
