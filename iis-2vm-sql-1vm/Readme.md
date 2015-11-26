# IIS VMs and SQL VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https ????.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates one or two Window Server 2012R2 VM(s) with IIS configured using DSC. It will also install one SQL Server 2014 standard edition VM.

A VNET with two subnets, NSG, loader balancer with NATing and probing rules are also created by this template.
