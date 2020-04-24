# Office 365 Desktop VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/windows-vm-O365/CredScanResult.svg)

**NOTE**: The VM image used in this sample can only be deployed to an MSDN subscription.

<a href="https://portal.azure.com/#create/microsoft.template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fwindows-vm-O365%2Fazuredeploy.json" target="_blank">

ARM Template to provision a VM complete with either Office 2013 or Office 2016 pre-installed.  

This is to assist the development and testing of O365 add-ins where the add-in must be tested in both versions (which cannot be installed side-by-side).

As per the Office apps and add-in validation policy 4.12 it must run in both versions: https://msdn.microsoft.com/en-us/library/office/jj220035.aspx


