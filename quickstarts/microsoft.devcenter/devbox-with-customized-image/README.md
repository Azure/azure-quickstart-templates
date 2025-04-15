---
description: This template would create all Dev Box admin resources as per Dev Box quick start guide (https&#58;//learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box). You can view all resources created, or directly go to DevPortal.microsoft.com to create your first Dev Box.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: devbox-with-customized-image
languages:
- bicep
- json
---
# Configure Dev Box service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-with-customized-image/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-with-customized-image%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-with-customized-image%2Fazuredeploy.json)   


This template would create all Dev Box admin resources as per [Dev Box quick start guide](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box). You can view all resources created, or directly go to [Dev Portal](https://devportal.microsoft.com) to create your first Dev Box.

If you're new to **Dev Box**, see:

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Quickstarts: Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Devcenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters`


## How to deploy

Click the "Deploy to Azure" button to deploy. There will be the deployment page as below:
![Deployment Sample](assets/deployment-page.png)

or Run the PowerShell script if you do not know how to get user principal id. 

### Microsoft.DevCenter

The resource provider "Microsoft.DevCenter" provides the capability to manage the Azure Dev Center.

- **Microsoft.DevCenter/devcenters**: include gallery, dev box definition
- **Microsoft.DevCenter/projects**: include project and dev box pool
- **Microsoft.DevCenter/networkConnections**: include network connection

## Parameters

When deploying this template you can provide parameters to customize the dev box and related resources.

| Parameters | Overview |
| -- | -- |
| User Principal Id | The AAD user id or gorup id that will be granted the role "Devcenter Dev Box User". Please find the user/group's object id under Azure Active Directory. If you don't provide this permission, the developer will not get the permission to access the project in the [Dev Portal](https://devportal.microsoft.com). If it's not provided, mannually you can also go to the project IAM and grant the related permissioin. Please refer to [here](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin#6-provide-access-to-a-dev-box-project). |
| Uer Principal Type | If you want to grant the permission to AAD group, please select "group" instead of "user" |

# Customize your own software and tools

If you want to add your own software and tools, please fork this repo and change the customizedCommand in the core/gallery.bicep
![customized-command](assets/customized-command.png)

# Add other customized image for Base, Java, .Net and Data

After you use this template to generate the customized image, if you want to generate more other types of image, please use the button below to generate customized image to your existing gallery and image definition.
| Image Type | Software and Tools |
| -- | -- |
| Base | Git, Azure CLI, VS Code, VS Code Extension for GitHub Copilot |
| Java | Git, Azure CLI, VS Code, Maven, OpenJdk11, VS Code Extension for Java Pack |
| .Net | Git, Azure CLI, VS Code，.Net SDK, Visual Studio |
| Data | Git, Azure CLI, VS Code，Python3, VS Code Extension for Python and Jupyter |

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-with-customized-image%2Fcustomized-image%2Fcustomized-image.json)


If you're new to **Dev Box**, see:

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Quickstarts: Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Devcenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters`