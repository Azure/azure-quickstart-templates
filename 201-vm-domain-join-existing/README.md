# Joins an Azure virtual machine into an AD Domain by using JsonADDomainExtension extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-domain-join-existing%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-domain-join-existing%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>

This template allows you to join an existing Windows virtual machine into an existing Windows Active Directory Domain.

For this template to work we need the following prerequisites to be met:

1. One or more virtual machines to join to a domain must exist beforehand
2. An Active Directory Forest must exist and a Domain Controller must be accessible by the virtual machine either on-premises or in Azure
3. The user that is required in this template must have the necessary rights to join computers to an Active Directory Domain
4. Domain DNS Name must be resolved by the virtual machine

Details about some of the parameters:

1. vmList - One or more virtual machines to domain join, comma separated. E.g. VM01, VM02, VM03, VM04
2. location - current location of the exising virtual machine. E.g. West US.
3. domainJoinUserName - this parameter must be in domain\username notation, where domain is the NetBios name of the domain. E.g. contoso\myAdmin
4. ouPath - This is an optional parameter that allows you to join this virtual machine into a specific OU instead of the default Computers container. E.g. OU=MyCorpComputers,DC=Contoso,DC=com


