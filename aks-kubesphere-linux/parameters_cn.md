参数
|	参数名	|	说明		|	默认值	|
| --------- | --------- | --------- |
| NetworkSecurityGroupName | 网络安全组名称 |  KubeSphereRG-NSG |
| virtualNetworkName | 虚拟网络名称 | ubeSphereRG-vnet |
| AKSresourceName | AKS 资源名称 | AKS-KubeSphere |
| vmSize | Kubernetes 集群节点和客户端节点的虚拟机大小 | Standard_F8s_v2 |
| osDiskSizeGB | Kubernetes 每个节点提供对的磁盘大小(单位 GB)，设置0将使用默认磁盘大小 | 0 |
| dnsPrefix | Kubernetes dnsPrefix | AKS-KubeSphere-dns |
| kubernetesVersion | Kubernetes 版本 | 1.18.14 |
| MasterNodeCount | Kubernetes Master 节点数 | 3 |
| WorkerNodeCount | Kubernetes Worker 节点数 | 3 |
| enablePrivateCluster | 启用私有集群 | false |
| authenticationType | 认证类型 | password |
| adminUsername | 客户端管理员用户名 | null |
| adminPassword | 客户端管理员用户密码 | null |
| sshPublicKey | 客户端管理员用户密钥 | null |
| CloudName | 该参数只对 Azure 中国区用户有效，中国区用户需将值改为"AzureChinaCloud" | AzureCloud |
| _artifactsLocation | 模版所需工具所在 URL，当模版使用附带脚步进行部署时，将自动合成脚步地址 |  |