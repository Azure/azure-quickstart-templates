参数
|	参数名	|	说明		|	默认值	|
| --------- | --------- | --------- |
| NetworkSecurityGroupName | 网络安全组名称 |  KubeSphereRG-NSG |
| virtualNetworkName | 虚拟网络名称 | ubeSphereRG-vnet |
| addressSpaces | 虚拟网络IP地址空间 | 10.10.0.0/16 |
| AKSSubnetName | AKS 子网名称 | KubeSphereRG-vnet-aks |
| AKSSubnetAddressRange | AKS 子网地址范围 | 10.10.128.0/20 |
| AKSServiceAddressRange | Kubernetes 范围地址空间(不要与任何子网地址范围重叠)| 10.0.0.0/16 |
| AKSdnsServiceIP | Kubernetes dns 服务IP地址 | 10.0.0.10 |
| dockerBridgeCidr | Docker 网桥 CIDR | 172.17.0.1/16 |
| ClientSubnetName | 客户端节点子网名称 | KubeSphereRG-vnet-client |
| ClientSubnetAddressRange | 客户端节点子网地址范围 | 10.10.10.0/24 |
| AKSresourceName | AKS 资源名称 | AKS-KubeSphere |
| vmSize | Kubernetes 集群节点和客户端节点的虚拟机大小 | Standard_F8s_v2 |
| osDiskSizeGB | Kubernetes 每个节点提供对的磁盘大小(单位 GB)，设置0将使用默认磁盘大小 | 0 |
| dnsPrefix | Kubernetes dnsPrefix | AKS-KubeSphere-dns |
| kubernetesVersion | Kubernetes 版本 | 1.18.14 |
| MasterNodeCount | Kubernetes Master 节点数 | 3 |
| WorkerNodeCount | Kubernetes Worker 节点数 | 3 |
| enablePrivateCluster | 启用私有集群 | false |
| ClientResourceName | 客户端资源名 | aksclient |
| ClientNodeNetworkInterfaceName | 客户端网络接口名称 | ksnode-nic |
| ClientNodeEnableAcceleratedNetworking | 启用客户端节点网络加速 | false |
| ClientosDiskType | 客户端磁盘类型 | StandardSSD_LRS |
| adminUsername | 客户端管理员用户名 | aksuser |
| adminPassword | 客户端管理员用户密码 | ABCabc321 |
| CloudName | 该参数只对 Azure 中国区用户有效，中国区用户需将值改为"AzureChinaCloud" | AzureGlobalCloud |
| SPName | 服务主体名称 | null |
| SPPassword | 服务主体密码 | null |
| SPTenant | 服务主体 tenant | null |
| SubscriptionID | 订阅 ID 号 | null |
| _artifactsLocation | 模版所需工具所在 URL，当模版使用附带脚步进行部署时，将自动合成脚步地址 |  |