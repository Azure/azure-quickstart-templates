# Deadline 7.2 template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/thinkbox-deadline/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fthinkbox-deadline%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fthinkbox-deadline%2Fazuredeploy.json)

  

This template creates a functioning Deadline 7.2 render environment on the Azure cloud platform. It includes a sample Maxwell render job and a standalone Krakatoa render job.

## Using Deadline

It will start a repository machine and any number of slave instances (default is 2). Resume the jobs to start rendering.
All output will be sent to C:\Data\Output on the Repository Virtual Machine.


