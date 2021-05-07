# Deploy Open edX Dogwood on multiple Ubuntu VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/opendx/openedx-scalable-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-scalable-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-scalable-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopendx%2Fopenedx-scalable-ubuntu%2Fazuredeploy.json)

This template deploys Open edX Dogwood on multiple Ubuntu VMs. The deployment creates multiple application VMs behind a load balancer, plus backend VMs for Mongo and MySQL. A default server-vars.yml is saved to */edx/app/edx_ansible*.

Note the following VM names to SSH between machines on the virtual network:
- Application VMs: openedx-app0, openedx-app1, etc
- MySQL VM: openedx-mysql
- Mongo VM: openedx-mongo

Installation can take 2+ hours after the deployment succeeds. An installation log is available on openedx-app0 at */var/log/azure/openedx-install.log*.

Connect to openedx-app0 with `ssh {adminUsername}@{dnsLabelPrefix}.{region}.cloudapp.azure.com -p 2220`.

You can learn more about Open edX here:
- [Open edX](https://open.edx.org)
- [Installation Options](https://openedx.atlassian.net/wiki/display/OpenOPS/Open+edX+Installation+Options)
- [Running FullStack](https://openedx.atlassian.net/wiki/display/OpenOPS/Running+Fullstack)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*


