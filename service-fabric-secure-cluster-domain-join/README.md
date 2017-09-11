# Very simple deployment of a 5 Node secure Service Fabric Cluster with Azure Diagnostics enabled

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a secure 5 node, Single Node Type Service fabric Cluster running Windows server 2012 R2 Data center on Standard_D2 Size VMs with Windows Azure diagnostics turned on. This template assumes that you already have certificates uploaded to your keyvault. 
This template is dependent on existing azure resources like storage accounts and vnets.


## Storage accounts (existing)

The storage accounts for diagnostics and logging should already exists. One storage account can be used for both or 2 storage accounts can be specified. One for logging and one for diagnositcs.

## Storage accounts vms

The names will not be random generated, but a parameter is used to define the name of the storage accounts. The index of the node will be added to make it unique.

## Virtual network (VNET)

Since the virtual machines in the scale set will join a domain we will join them to an existing virtual network.

## Loadbalancer

The loadbalancer that gets created is an internal loadbalancer. Meaning your cluster will not be public available. It will be available inside the domain.

## Domain join

The virtual machine scale set has an extension configured to join an existing domain.


# Parameters

1. clusterLocation: The location of the service fabric cluster.
2. clusterName: The name of the service fabric cluster.
3. adminUsername: The admin user name to connect to the vm. (This is temporary since the vm joins a domain)
4. adminPassword: The admin password to connect to the vm. (This is temporary since the vm joins a domain)
5. certificateStorevalue: The certificate store.
6. certificateThumbPrint: The thumbprint of the certificate
7. existingKeyVaultName: The name of key vault.
8.  certificateUrlValue: The url of the certificate.
9. nt0InstanceCount: Number of nodes.
10. vmNodeType0Name: The name of the nodes. This will also be the name of the servers in the domain. 0000N will be added.
11. storageAccountsName: The name of the existing storage account where diagnostic and logging will be stored. (supportLogStorageAccountName, applicationDiagnosticsStorageAccountName can be used alternativly if you want seperate storage accounts)
12. vmStorageAccountsName: The storage account name for the disks of the VMs.
13. domainToJoin: The domain to join. Example: contoso.be
14. domainUsername: The username that will perform the domain join. Standard users can perform 10 domain joins. If your cluster has more then 10 nodes, choose an account that can join more then 10 servers. Example: contoso\DomainAdmin
15. domainPassword: The password of the domain user performing the domain join.
16. ouPath: Specifies an organizational unit (OU) for the domain account. Enter the full distinguished name of the OU in quotation marks. Example: 'OU=testOU; DC=domain; DC=Domain; DC=com
17. domainJoinOptions: Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx
18. subnet0Prefix: The subnet prefix.
19. internalLBAddress: The ip address of the internal load balancer
20. existingVNetRGName: The resource group of the virtual network.
21. existingVNetName: The name of the virtual network.
22. existingSubnetName: The name of the subnet.
23. nsgName: The name of the network security group.
24. loadbalancerName: The name of the internal loadbalancer.



