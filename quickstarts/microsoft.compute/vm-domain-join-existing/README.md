# Joins an Azure virtual machine into an AD Domain by using JsonADDomainExtension extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-domain-join-existing/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-domain-join-existing%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-domain-join-existing%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-domain-join-existing%2Fazuredeploy.json)

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
