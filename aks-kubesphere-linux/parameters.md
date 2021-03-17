parameters
|	parameters	|	Explanation		|	default value	|
| --------- | --------- | ------ |
| NetworkSecurityGroupName | Name of new or existing network security group |  KubeSphereRG-NSG |
| virtualNetworkName | Name of new or existing virtual network | KubeSphereRG-vnet |
| AKSresourceName | The name of AKS resource | AKS-KubeSphere |
| vmSize | Kubernetes Cluster virtual machine resource size | Standard_F8s_v2 |
| osDiskSizeGB | Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize. | 0 |
| dnsPrefix | Optional DNS prefix to use with hosted Kubernetes API server FQDN | AKS-KubeSphere-dns |
| kubernetesVersion | The version of Kubernetes | 1.18.14 |
| MasterNodeCount | The number of Master node | 3 |
| WorkerNodeCount | The number of Worker node | 3 |
| enablePrivateCluster | Enable private network access to the kubernetes cluster. | false |
| authenticationType | Authentication type | password |
| adminUsername | Client node admin user name | null |
| adminPassword | Client node admin user password | null |
| sshPublicKey | ssh key for the Virtual Machine | null |
| CloudName | AzureChinaCloud users should change it | AzureCloud |
| _artifactsLocation | The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated | null |