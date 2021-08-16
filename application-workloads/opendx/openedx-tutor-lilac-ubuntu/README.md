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
# Template Parameters

When you launch the installation, you need to specify the following parameters:

* `dnsLabelPrefix`: this is the public DNS name for the VM. You just need to specify an unique name.
* `adminPasswordOrKey`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `vmSize`: The type of VM that you want to use for the node. The default size is Standard_D3_v2, but you can change that if you expect to run workloads that require more RAM or CPU resources. The allowed values have been listed.

# Script to deploy Tutor

This template deploys the Open edX (Lilac release) through tutor on Ubuntu. After deploying the template, the prerequisite software needed to run tutor (docker, docker-compose) and tutor will be installed in the VM.
A default deploy_tutor.sh is saved to /home/openadmin, which can be used to deploy the open edx (Lilac release) and create an admin user by command "./deploy_tutor.sh". The whole procedure should require less than 10 minutes and a few questions about the Configuration of your Open edX platform will be asked. 

Connect to the virtual machine with SSH: `ssh openadmin@{PublicIPAddress}`. Installation log can be found under */var/log/azure*.

# How to check that all resources were set up successfully
* Check if `docker`, `docker-compose` and `tutor`:
docker --version, docker-compose --version and tutor --version
(images/version_check.png)

# More About Open edX and Tutor

You can learn more about Open edX and tutor here:
- [Open edX](https://open.edx.org)
- [Tutor tutorial](https://docs.tutor.overhang.io/)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*


