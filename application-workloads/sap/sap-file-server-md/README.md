# SAP NetWeaver file server using a Marketplace image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-file-server-md/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-file-server-md%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-file-server-md%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-file-server-md%2Fazuredeploy.json)

This template takes a minimum amount of parameters and deploys an NFS on SLES, GlusterFS on RHEL or Windows Server 2016 Storage Spaces Direct Scale out File Server that is customized for use with SAP NetWeaver, using the latest version of the selected operating system. It deploys 2 (3 for GlusterFS) virtual machines in an Availability Sets and a Load Balancer is added to allow HA configurations in the operating system (e.g. Windows Failover Cluster) if required.

## Internal Load Balancer ports

* Windows specific ports 445, 5985
* SLES NFS ports 2049 (TCP and UDP)
* no Load Balancer for RHEL and GlusterFS required

Internal Load Balancer probe port: **61000**
