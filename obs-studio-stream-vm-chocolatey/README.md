# Blank Template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg)

This is an empty template and parameters file with the schema reference and top-level properties defined.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIhorLeontiev%2Fazure-quickstart-templates%2Fobs-vm%2Fobs-studio-stream-vm-chocolatey%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIhorLeontiev%2Fazure-quickstart-templates%2Fobs-vm%2Fobs-studio-stream-vm-chocolatey%2Fazuredeploy.json)



`Tags: Azure, Virtual Machine, OBS, OBS Studio, Streaming VM`

## Solution overview and deployed resources
This template deploys a Windows GPU VM (Windows 10) with OBS Studio, Skype and Microsoft Teams Preinstalled. 

Following resources will be created
- Virtual Network
- Public IP Adress with DNS
- Network Interface
- Network Security group (with RDP port opened)
- Virtual Machine

Notes
- GPU drivers installed via NVIDIA extension for Virtual Machine, more details - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup
- Software installation based on custom script extension via chocolatey package manager

**