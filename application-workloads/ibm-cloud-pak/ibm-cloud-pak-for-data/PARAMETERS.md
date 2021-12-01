### Description of all the parameters used in the AzureDeploy.json
| Parameters             | Default       | Description          |
| --------------------- | :-----------: | -------------------- |
| `aadClientId` | - | Follow steps [here](https://github.ibm.com/IIG/cpd_terraform/tree/master/azure#steps-to-deploy). The `appId` in the json after the `az ad sp create-for-rbac` command goes here. |
| `aadClientSecret` | - | Follow steps [here](https://github.ibm.com/IIG/cpd_terraform/tree/master/azure#steps-to-deploy). The `password` in the json after the `az ad sp create-for-rbac` command goes here. |
| `resourceGroup` | mycpd-rg | Resource Group to contain deployment related resources. |
| `clusterName` | mycpd-cluster | All resources created by the Openshift Installer will have this name as prefix |
| `dnszoneRG` | - | Follow steps [here](https://github.ibm.com/IIG/cpd_terraform/tree/master/azure#steps-to-deploy) to create an App Service Domain. For a private cluster, create a Private DNS Zone instead. Enter the resource group created. |
| `dnsZone` | - | Follow steps [here](https://github.ibm.com/IIG/cpd_terraform/tree/master/azure#steps-to-deploy) to create an App Service Domain. Enter the dnszone name here |
| `newOrExistingNetwork` | new | Deploy cluster into new or existing network. NOTE: If using existing, you must deploy the cluster into the same region as the network |
| `existingVnetResourceGroupName` | - | If existing network is to be used, enter it's resource group here |
| `virtualNetworkName` | ocpfourx-vnet | Name of new or existing virtual network |
| `virtualNetworkCIDR` | 10.0.0.0/16 | Address space of the virtual network. NOTE: Do not use a 192.* prefixed network, as this is reserved for the serviceNetwork. See [link](https://docs.openshift.com/container-platform/4.3/installing/installing_azure/installing-azure-vnet.html) for more details. |
| `bastionSubnetName` | bootnode-subnet | Subnet Name to deploy bootnode VM in. |
| `bastionSubnetPrefix` | 10.0.3.0/24 | Address space to deploy bootnode VM in. |
| `masterSubnetName` | master-subnet | Subnet Name to deploy control plane nodes in. |
| `masterSubnetPrefix` | 10.0.1.0/24 | Address space to deploy control plane nodes in. |
| `workerSubnetName` | worker-subnet | Subnet Name to deploy control plane nodes in. |
| `workerSubnetPrefix` | 10.0.2.0/24 | Address space to deploy compute nodes in. |
| `singleZoneOrMultiZone` | multi | Deploy Openshift Cluster into a single zone or a multi-zone. If multi is selected, ensure the region selected supports Availability Zone. See [link](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview#services-support-by-region) |
| `masterInstanceCount` | 3 | Number of control plane nodes |
| `workerInstanceCount` | 3 | Number of compute nodes |
| `bastionVmSize` | Standard_D8_v3 | Default has 8vcpus and 32gb RAM. Use [Azure VM sizing](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes) for more information. |
| `masterVmSize` | Standard_D8_v3 | Default has 8vcpus and 32gb RAM. Use [Azure VM sizing](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes) for more information. |
| `workerVmSize` | Standard_D16_v3 | Default has 16vcpus and 64gb RAM. Use [Azure VM sizing](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes) for more information. |
| `pullSecret` | - | The pull secret that you obtained from the [Pull Secret](https://cloud.redhat.com/openshift/install/pull-secret) page on the Red Hat OpenShift Cluster Manager site. You use this pull secret to authenticate with the services that are provided by the included authorities, including Quay.io, which serves the container images for OpenShift Container Platform components. |
| `enableFips` | true | If FIPS mode is enabled, the Red Hat Enterprise Linux CoreOS (RHCOS) machines that OpenShift Container Platform runs on bypass the default Kubernetes cryptography suite and use the cryptography modules that are provided with RHCOS instead. |
| `adminUsername` | core | Admin username for the bootnode |
| `sshPublicKey` | - | SSH Public key to be included in the bootnode and all the nodes in the cluster. Example: "ssh-rsa AAAAB3Nza..." |
| `privateOrPublicEndpoints` | public | Public or Private. Set publish to Private to deploy a cluster which cannot be accessed from the internet. See [documentation](https://docs.openshift.com/container-platform/4.3/installing/installing_azure/installing-azure-private.html#private-clusters-default_installing-azure-private) for more details. |
| `outboundType` | Loadbalancer | User Azure Loadbalancer or assume User Defined Routing has been setup on the vNet. Options are `Loadbalancer` and `UserDefinedRouting` |
| `publicBootnodeIP` | true | Public IP attached to the bootnode|
| `enableAutoscaler` | false | Enable/Disable Openshift Machine Autoscaler|
| `storageOption` | nfs | nfs, ocs or portworx. Storage option to use. |
| `portworxSpecUrl` | - | Generate a specification file the [portworx-central](https://central.portworx.com/dashboard). See PORTWORX.md. |
| `storageDiskSize` | 1024 | Data disk size. Only applicable for NFS storage |
| `projectName` | zen | Openshift namespace or project to deploy CPD into |
| `apiKey` | - | API Key. Follow steps [here](https://github.ibm.com/IIG/cpd_terraform/tree/master/azure#steps-to-deploy) |
| `installDataVirtualization` | no | Install Data Virtualization Add-On |
| `installWatsonStudioLocal` | no | Install Watson Studio Library Add-On |
| `installWatsonKnowledgeCatalog` | no | Install Watson Knowledge Catalog Add-On |
| `installWatsonOpenscaleAndWatsonMachineLearning` | no | Install Watson AI Openscale Add-On |
| `installWatsonMachineLearning` | no | Install Watson Machine Learning Add-On |
| `installCognosDashboard` | no | Install Cognos Dashboard |
| `installAnalyticsEngine` | no | Install AnalyticsEngine |
