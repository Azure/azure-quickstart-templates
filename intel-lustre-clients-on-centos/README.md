# Intel Lustre 2.7 clients on CentOS 6.6 or 7.0 gallery image

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fintel-lustre-clients-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fintel-lustre-clients-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates 2 or more Intel Lustre 2.7 client virtual machines using Azure gallery CentOS 6.6 or 7.0 image and mounts an existing Intel Lustre filesystem.

* <a href="https://wiki.hpdd.intel.com/display/PUB/Why+Use+Lustre" target="_blank">Why Use Lustre?</a>
* Intel Lustre clients must be deployed into an **existing Virtual Network** that already contains operational Intel Lustre filesystem consisting of MGS (management server), MDS (metadata server), and OSS (object storage server) nodes.
* The actual Lustre filesystem is deployed via the solution template from Azure Marketplace <a href="https://azure.microsoft.com/en-us/marketplace/partners/intel/" target="_blank">Intel Cloud Edition for Lustre* Software - Eval</a>
* When deploying this template, you will need to provide the private IP address of the MGS node (e.g. 10.1.0.4) and the name of the filesystem that was created when Lustre servers were deployed (e.g. scratch)
* Client nodes will mount the Lustre filesystem at mount point like /mnt/FILESYSTEMNAME (e.g. /mnt/scratch)
* You can view the <a href="https://build.hpdd.intel.com/job/lustre-manual/lastSuccessfulBuild/artifact/lustre_manual.xhtml#idp5145472" target="_blank">stripe_size and stripe_count</a> of the mounted filesystem using command like "lfs getstripe /mnt/scratch"
* All of the client nodes will be deployed into the same availability-set since this is required for HPC Linux RDMA functionality over InfiniBand (although, currently to use RDAM special custom Linux image must be used)
* Public IP will be attached to the client0 node. That node can be accessed via SSH  [dnsNamePrefix].[region].cloudapp.azure.com.
* Intel Lustre kernel modules are dynamically compiled for the currently running kernel using instructions outlined in https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel
* <a href="https://wiki.hpdd.intel.com/display/PUB/Intel+Cloud+Edition+for+Lustre+on+Azure" target="_blank">Learn more about Intel Cloud Edition for Lustre on Azure</a>
* <a href="https://build.hpdd.intel.com/job/lustre-manual/lastSuccessfulBuild/artifact/lustre_manual.xhtml" target="_blank">Lustre Manual</a>
* If you are interested in getting more information or participating in an evaluation of Intel Lustre on Azure please contact Intel at <a href="mailto:hpdd-azure@intel.com?subject=Azure-Quick-Start-Templates">hpdd-azure@intel.com</a>
