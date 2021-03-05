parameters
|	parameters	|	Explanation		|	default value	|
| --------- | --------- | ------ |
| NetworkSecurityGroupName | Name of new or existing network security group |  KubeSphereRG-NSG |
| virtualNetworkName | Name of new or existing virtual network | ubeSphereRG-vnet |
| addressSpaces | The spaces of address | 10.10.0.0/16 |
| AKSSubnetName | The name of new or existing AKS subnet | KubeSphereRG-vnet-aks |
| AKSSubnetAddressRange | The address range of AKS subnet | 10.10.128.0/20 |
| AKSServiceAddressRange | The address range of AKS service, it must not overlap with any subnet IP ranges | 10.0.0.0/16 |
| AKSdnsServiceIP | The dns  service IP in AKS | 10.0.0.10 |
| dockerBridgeCidr | The bridge cidr for docker | 172.17.0.1/16 |
| ClientSubnetName | The name of new or existing client subnet | KubeSphereRG-vnet-client |
| ClientSubnetAddressRange | The address range of client node subnet | 10.10.10.0/24 |
| AKSresourceName | The name of AKS resource | AKS-KubeSphere |
| vmSize | Kubernetes Cluster virtual machine resource size | Standard_F8s_v2 |
| osDiskSizeGB | Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize. | 0 |
| dnsPrefix | Optional DNS prefix to use with hosted Kubernetes API server FQDN | AKS-KubeSphere-dns |
| kubernetesVersion | The version of Kubernetes | 1.18.14 |
| MasterNodeCount | The number of Master node | 3 |
| WorkerNodeCount | The number of Worker node | 3 |
| enablePrivateCluster | Enable private network access to the kubernetes cluster. | false |
| ClientResourceName | The name of AKS client node | aksclient |
| ClientNodeNetworkInterfaceName | The name of new or existing client node network interface | ksnode-nic |
| ClientNodeEnableAcceleratedNetworking | Enable client node network accelerated | false |
| ClientosDiskType | Client os Disk type | StandardSSD_LRS |
| adminUsername | Client node admin user name | aksuser |
| adminPassword | Client node admin user password | ABCabc321 |
| CloudName | AzureChinaCloud users should change it | AzureGlobalCloud |
| SPName | Service Principal User Name | null |
| SPPassword | Service Principal User Password | null |
| SPTenant | Service Principal User Tenant | null |
| _artifactsLocation | The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated | null |
| SubscriptionID | Subscription ID | null |