# Deploy Open edX (Lilac release) through tutor on Ubuntu

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-devstack-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-devstack-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-devstack-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-devstack-ubuntu%2Fazuredeploy.json)

# What is tutor?

```
Tutor is the Docker-based Open edX distribution, both for production and local development. 
Open edx can be scaled, upgraded, customerized and deployed easily through it. 
Tutor is reliable, fast and extensible, which has been used by hundreds of Open edX platforms around the world.
After 'tutor local quickstart', A full, production-ready Open edX platform (Lilac release) will run with docker-compose.
```

This template deploys the Open edX (Lilac release) through tutor on Ubuntu. A default deploy_tutor.sh is saved to /home/openadmin, which can deploy the open edx (Lilac reease) and create an admin user by command "./deploy_tutor.sh". 

Connect to the virtual machine with SSH: `ssh openadmin@{PublicIPAddress}`. Installation log can be found under */var/log/azure*.

You can learn more about Open edX and tutor here:
- [Open edX](https://open.edx.org)
- [Tutor tutorial](https://docs.tutor.overhang.io/)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*


