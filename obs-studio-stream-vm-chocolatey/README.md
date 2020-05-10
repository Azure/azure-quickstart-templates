# OBS Studio on Windows 10 GPU VM with Skype, NDI Runtime and OBS-NDI installed


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

*OBS-NDI is isntalling via Powershell, not via chocolatey as OBS-NDI package not validated yet by chocolatey moderators Team - https://chocolatey.org/packages/obs-ndi/4.9.0*


Sogtware preinstalled
- Skype - https://chocolatey.org/packages/skype
- MS Teams - https://chocolatey.org/packages/microsoft-teams
- OBS Studio - https://chocolatey.org/packages/obs-studio
- NDI Runtime - https://ndi.tv/tools/
- OBS-NDI - https://github.com/Palakis/obs-ndi/releases