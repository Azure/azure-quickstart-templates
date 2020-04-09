# Stream Processing Using NCache Continuous Query

## Introduction

This ARM template deloys N number of NCache VMs and creates a cluster of N nodes of the provided cache name. Latest NCache market place image is picked from market place for deployment.

## PreRequisits
"NCacheConfiguration.ps1" file to be uploaded as blob. Following is the link to upload files on azure storage account as blob.
https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal

## ARM Template Parameters 

### ClusterName
Name of the Cache 

### NumberOfVMs
Number of instances of NCache market place image you want to deploy on azure.

### FirstName
FirstName of User

### LastName
Last Name of User

### Company
Company name of User.

### EmailAddress
Email Address of User.

### Environment Name
Environment Name of user which will be used in licensing.

### NumberOfClients
Maximum Number of clients which will allowed to connected with each node. Used in license activation.

### LicenseKey
NCache license key

### CacheTopology
Defines the caching topolgy of the cache which will be created.

### ReplicationStrategy
Cache replication strategy whether asynchronous or synchronous 

### CacheSize
Size of the cache in MBs

### EvictionPolicy
Eviction policy of cache. Least recently used, Least Frequenctly used, Priority.

### EvictionPercentage
Percentage of eviction

### VirtualMachineNamePrefix
Prefix of NCache VM

### VirtualMachineSize
Name of the Cache 

### AdminUserName
Adminitrator Username of NCacheVM 

### AdminPassword
Adminitrator Password of NCacheVM 

### AddressPrefix
Address prefix of VNET

### SubnetName
Subnet name in VNET

### SubnetPrefix
Subet address prefix in VNET

### VirtualNetworkName
VNET Name

### NCacheClusterCreationScriptFileUri
URI of Blob storage of "NCacheConfiguration.ps1" file. Which will be uploaded by the user before deploying the template. This Script will create a NCache Cluster and is mandatory to upload.




 







 



 



