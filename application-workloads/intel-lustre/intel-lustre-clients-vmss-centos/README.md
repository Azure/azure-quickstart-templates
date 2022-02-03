# Azure VM Scale Set as clients of Intel Lustre shared parallel filesystem

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/intel-lustre/intel-lustre-clients-vmss-centos/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fintel-lustre%2Fintel-lustre-clients-vmss-centos%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fintel-lustre%2Fintel-lustre-clients-vmss-centos%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fintel-lustre%2Fintel-lustre-clients-vmss-centos%2Fazuredeploy.json)

This template creates an Azure VM Scale Set with 1-99 of Intel Lustre 2.7 client virtual machines using Azure gallery CentOS 6.6 or 7.0 image and mounts an existing Intel Lustre filesystem.

- [Why Use Lustre?](https://wiki.hpdd.intel.com/display/PUB/Why+Use+Lustre)

- Intel Lustre clients must be deployed into an **existing Virtual Network*- that already contains operational Intel Lustre filesystem consisting of MGS (management server), MDS (metadata server), and OSS (object storage server) nodes.

- The actual Lustre filesystem is deployed via the solution template from Azure Marketplace [Intel Cloud Edition for Lustre- Software - Eval](https://azure.microsoft.com/en-us/marketplace/partners/intel/)

- When deploying this template, you will need to provide the private IP address of the MGS node (e.g. 10.1.0.4) and the name of the filesystem that was created when Lustre servers were deployed (e.g. scratch)

- Client nodes will mount the Lustre filesystem at mount point like /mnt/FILESYSTEMNAME (e.g. /mnt/scratch)

- You can view the [stripe_size and stripe_count of the mounted filesystem](https://build.hpdd.intel.com/job/lustre-manual/lastSuccessfulBuild/artifact/lustre_manual.xhtml#idp5145472) using command like "lfs getstripe /mnt/scratch"

- All client nodes can be accessed via SSH via the public IP (vmss-[vmssName]-[uniqueString].[region].cloudapp.azure.com) and ports 50000 (for instance 0) and 50099 (for instance 99).

- Intel Lustre kernel modules are dynamically compiled for the currently running kernel using instructions outlined [here](https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel)

- Learn more about [Intel Cloud Edition for Lustre on Azure](https://wiki.hpdd.intel.com/display/PUB/Intel+Cloud+Edition+for+Lustre+on+Azure)

- [Lustre Manual](https://build.hpdd.intel.com/job/lustre-manual/lastSuccessfulBuild/artifact/lustre_manual.xhtml)

- If you are interested in getting more information or participating in an evaluation of Intel Lustre on Azure please contact Intel at [hpdd-azure@intel.com](mailto:hpdd-azure@intel.com?subject=Azure-Quick-Start-Templates)

## Scale Up or Down

To scale up or down an existing Virtual Machine ScaleSet, simply deploy the template again, to the resource group that contains the existing ScaleSet and provide the appropriate values for NewOrScaleExisting and the clientVmSize and clientCount.
