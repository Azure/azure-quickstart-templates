# OBS Studio on Windows 10 GPU VM with Skype, NDI Runtime and OBS-NDI installed

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/obs/obs-studio-stream-vm-chocolatey/CredScanResult.svg)


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fobs%2Fobs-studio-stream-vm-chocolatey%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fobs%2Fobs-studio-stream-vm-chocolatey%2Fazuredeploy.json)

`Tags: Azure, Virtual Machine, OBS, OBS Studio, Streaming VM`

## Solution overview and deployed resources
This template deploys a Windows GPU VM (Windows 10) with OBS Studio, and Skype Preinstalled. 

Following resources will be created
- Virtual Network
- Public IP Adress with DNS
- Network Interface
- Network Security group (with RDP port opened)
- Virtual Machine

Notes
- GPU drivers installed via NVIDIA extension for Virtual Machine, more details - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup
- Software installation based on custom script extension via chocolatey package manager

*OBS-NDI is isntalling via choco sources, as OBS-NDI official package not yet validated by chocolatey moderators Team - https://chocolatey.org/packages/obs-ndi/4.9.0*


Software preinstalled
- Skype - https://chocolatey.org/packages/skype
- OBS Studio - https://chocolatey.org/packages/obs-studio
- NDI Runtime - https://ndi.tv/tools/
- OBS-NDI - https://github.com/Palakis/obs-ndi/releases

Allowed VM sizes in template
- Standard_NV6_Promo
- Standard_NV12_Promo       
- Standard_NV24_Promo
- Standard_NC6_Promo
- Standard_NC12_Promo
- Standard_NC24_Promo
- Standard_NV6
- Standard_NV12            
- Standard_NV24
- Standard_NC6
- Standard_NC12
- Standard_NC24
- Standard_NV6s_v2
- Standard_NV12s_v2
- Standard_NV24s_v2
- Standard_NV12s_v3
- Standard_NV24s_v3
- Standard_NV48s_v3
- Standard_NC6
- Standard_NC12
- Standard_NC24
