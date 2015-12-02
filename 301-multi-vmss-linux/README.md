# Deployment of Multiple VM Scale Sets of Linux VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-multi-vmss-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><a  target="_blank">

This template allows you to deploy multiple VM Scale Sets of Linux VMs.

PARAMETER RESTRICTIONS
======================

vmssPrefix must be 8 characters in length or shorter.
numberOfVMSS must be 5 or less.
instanceCountPerVMSS must be 100 or less.
