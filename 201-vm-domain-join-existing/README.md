# Joins an Azure virtual machine into an AD Domain by using JsonADDomainExtension extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-domain-join-existing%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to join an exitsing Windows virtual machine into an existing Windows Active Directory Domain.

For this template to work we need the following pre-requisits to be met:

1. Virtual machine to join to a domain must exist beforehand
2. An Active Directory Forest must exist and a Domain Controller must be accessible by the virtual machine either on-premises or in Azure
3. The user that is required in this template must have the necessary rights to join computers to an Active Directory Domain
4. Domain DNS Name must be resolved by the virtual machine

Details about some of the parameters:

1. location - current location of the exising virtual machine. E.g. West US.
1. dominJoinUserName - this parameter must be in domain\username notation, where domain is the NetBios name of the domain. E.g. contoso\myAdmin
2. ouPath - This is an optional parameter that allows you to join this virtual machine into a specific OU instead of the default Computers container. E.g. OU=MyCorpComputers,DC=Contoso,DC=com


