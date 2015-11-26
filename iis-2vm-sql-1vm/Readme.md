# IIS VMs and SQL VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Falibaloch%2Fazure-quickstart-templates%2Fblob%2Fmaster%2Fiis-2vm-sql-1vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
This template creates one or two Window Server 2012R2 VM(s) with IIS configured using DSC. It will also install one SQL Server 2014 standard edition VM.

A VNET with two subnets, NSG, loader balancer with NATing and probing rules are also created by this template.
