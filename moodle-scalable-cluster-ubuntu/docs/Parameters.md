# Moodle on Azure Parameters

Our goal with these templates is to make it as easy as possible to
deploy a Moodle on Azure cluster that can be customized to your
specific needs. To that end we provide a great manay configuration
options. This document attempts to document all these parameters,
however, like all documentation it can sometimes fall behind. For a
canonical reference you should review the `azuredeploy.json` file.

## Extracting documentation from azuredeploy.json

To make it a litte easier to read `azuredeploy.json` you might want to
run the following commands which will extract the necessary
information and display it in a more readable form.

```bash
sudp apt install jq
```

``` bash
jq -r '.parameters | to_entries[] | "### " + .key + "\n\n" + .value.metadata.description + "\n\nType: " + .value.type + "\n\nPossible Values: " + (.value.allowedValues | @text) + "\n\nDefault: " + (.value.defaultValue | @text) + "\n\n"' azuredeploy.json
```

## Available Parameters

### _artifactsLocation

The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.

Type: string

Possible Values: null

Default: https://raw.githubusercontent.com/Azure/Moodle/master/


### _artifactsLocationSasToken

The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.

Type: securestring

Possible Values: null

Default: 


### applyScriptsSwitch

Switch to process or bypass all scripts/extensions

Type: bool

Possible Values: null

Default: true


### autoscaleVmCount

Maximum number of autoscaled web VMs

Type: int

Possible Values: null

Default: 10


### autoscaleVmSku

VM size for autoscaled web VMs

Type: string

Possible Values: null

Default: Standard_DS2_v2


### azureBackupSwitch

Switch to configure AzureBackup and enlist VM's

Type: bool

Possible Values: null

Default: false


### azureSearchSku

The search service level you want to create

Type: string

Possible Values: ["free", "basic", "standard", "standard2", "standard3"]

Default: basic


### azureSearchReplicaCount

Replicas distribute search workloads across the service. You need 2 or more to support high availability (applies to Basic and Standard only)

Type: int

Possible Values: null 

Default: 3


### azureSearchPartitionCount

Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple Azure Search units

Type: int

Possible Values: [1,2,3,4,6,12]

Default: 1


### azureSearchHostingMode

Applicable only for azureSearchSku set to standard3. You can set this property to enable a single, high density partition that allows up to 1000 indexes, which is much higher than the maximum indexes allowed for any other azureSearchSku.

Type: string

Possible Values: ["default", "highDensity"]

Default: default
 

### caCertKeyVaultURL

Azure Key Vault URL for your stored CA (Certificate Authority) cert. This value can be obtained from keyvault.sh output if you used the script to store your CA cert in your Key Vault. This parameter is ignored if the keyVaultResourceId parameter is blank.

Type: string

Possible Values: null

Default: 


### caCertThumbprint

Thumbprint of your stored CA cert. This value can be obtained from keyvault.sh output if you used the script to store your CA cert in your Key Vault. This parameter is ignored if the keyVaultResourceId parameter is blank.

Type: string

Possible Values: null

Default: 


### controllerVmSku

VM size for the controller VM

Type: string

Possible Values: null

Default: Standard_DS1_v2


### dbLogin

Database admin username

Type: string

Possible Values: null

Default: dbadmin


### dbServerType

Database type

Type: string

Possible Values: ["postgres","mysql","mssql"]

Default: mysql


### elasticVmSku

VM size for the elastic search nodes

Type: string

Possible Values: null

Default: Standard_DS2_v2


### fileServerDiskCount

Number of disks in raid0 per gluster node or nfs server

Type: int

Possible Values: null

Default: 4


### fileServerDiskSize

Size per disk for gluster nodes or nfs server

Type: int

Possible Values: null

Default: 127


### fileServerType

File server type: GlusterFS, NFS--not yet highly available

Type: string

Possible Values: ["gluster","nfs"]

Default: nfs


### subnetGateway

name for Virtual network gateway subnet

Type: string

Possible Values: ["GatewaySubnet"]

Default: GatewaySubnet


### gatewayType

Virtual network gateway type

Type: string

Possible Values: ["Vpn","ER"]

Default: Vpn


### glusterVmSku

VM size for the gluster nodes

Type: string

Possible Values: null

Default: Standard_DS2_v2


### htmlLocalCopySwitch

Switch to create a local copy of /moodle/html or not

Type: bool

Possible Values: null

Default: true


### installGdprPluginsSwitch

Switch to install Moodle GDPR plugins. Note these require Moodle versions 3.4.2+ or 3.3.5+ and these will be included by default in Moodle 3.5

Type: bool

Possible Values: null

Default: false


### installO365pluginsSwitch

Switch to install Moodle Office 365 plugins

Type: bool

Possible Values: null

Default: false


### installObjectFsSwitch

Switch to install Moodle Object FS plugins (with Azure Blob storage)

Type: bool

Possible Values: null

Default: false


### keyVaultResourceId

Azure Resource Manager resource ID of the Key Vault in case you stored your SSL cert in an Azure Key Vault (Note that this Key Vault must have been pre-created on the same Azure region where this template is being deployed). Leave this blank if you didn't. Resource ID example: /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/yyy. This value can be obtained from keyvault.sh output if you used the script to store your SSL cert in your Key Vault.

Type: string

Possible Values: null

Default: 


### moodleVersion

The Moodle version you want to install.

Type: string

Possible Values: ["MOODLE_34_STABLE","v3.4.2","v3.4.1","MOODLE_33_STABLE","MOODLE_32_STABLE","MOODLE_31_STABLE","MOODLE_30_STABLE","MOODLE_29_STABLE"]

Default: MOODLE_34_STABLE


### mssqlDbEdition

MS SQL DB edition

Type: string

Possible Values: ["Basic","Standard"]

Default: Standard


### mssqlDbServiceObjectiveName

MS SQL database service object names

Type: string

Possible Values: ["S1","S2","S3","S4","S5","S6","S7","S9"]

Default: S1


### mssqlDbSize

MS SQL database size

Type: string

Possible Values: ["100MB","250MB","500MB","1GB","2GB","5GB","10GB","20GB","30GB","40GB","50GB","100GB","250GB","300GB","400GB","500GB","750GB","1024GB"]

Default: 250GB


### mssqlVersion

Mssql version

Type: string

Possible Values: ["12.0"]

Default: 12.0


### mysqlPgresSkuHwFamily

MySql/Postgresql sku hardware family

Type: string

Possible Values: ["Gen4","Gen5"]

Default: Gen4


### mysqlPgresSkuTier

MySql/Postgresql sku tier

Type: string

Possible Values: ["Basic","GeneralPurpose","MemoryOptimized"]

Default: GeneralPurpose


### mysqlPgresStgSizeGB

MySql/Postgresql storage size in GB. Minimum 5GB, increase by 1GB, up to 1TB (1024 GB)

Type: int

Possible Values: null

Default: 125


### mysqlPgresVcores

MySql/Postgresql vCores. For Basic tier, only 1 & 2 are allowed. For GeneralPurpose tier, 2, 4, 8, 16, 32 are allowed. For MemoryOptimized, 2, 4, 8, 16 are allowed.

Type: int

Possible Values: [1,2,4,8,16,32]

Default: 2


### mysqlVersion

Mysql version

Type: string

Possible Values: ["5.6","5.7"]

Default: 5.7


### postgresVersion

Postgresql version

Type: string

Possible Values: ["9.5","9.6"]

Default: 9.6


### redisDeploySwitch

Switch to deploy a redis cache or not

Type: bool

Possible Values: null

Default: true


### searchType

Options of Moodle Global Search

Type: string

Possible Values: ["none", "azure", "elastic"]

Default: none


### siteURL

URL for Moodle site

Type: string

Possible Values: null

Default: www.example.org


### sshPublicKey

ssh public key

Type: string

Possible Values: null

Default: null


### sshUsername

ssh user name

Type: string

Possible Values: null

Default: azureadmin


### sslCertKeyVaultURL

Azure Key Vault URL for your stored SSL cert. This value can be obtained from keyvault.sh output if you used the script to store your SSL cert in your Key Vault. This parameter is ignored if the keyVaultResourceId parameter is blank.

Type: string

Possible Values: null

Default: 


### sslCertThumbprint

Thumbprint of your stored SSL cert. This value can be obtained from keyvault.sh output if you used the script to store your SSL cert in your Key Vault. This parameter is ignored if the keyVaultResourceId parameter is blank.

Type: string

Possible Values: null

Default: 


### sslEnforcement

MySql/Postgresql SSL connection

Type: string

Possible Values: ["Disabled","Enabled"]

Default: Disabled


### storageAccountType

Storage Account type

Type: string

Possible Values: ["Standard_LRS","Standard_GRS","Standard_ZRS"]

Default: Standard_LRS


### vNetAddressSpace

Address range for the Moodle virtual network - presumed /16 - further subneting during vnet creation

Type: string

Possible Values: null

Default: 172.31.0.0


### vnetGwDeploySwitch

Switch to deploy a virtual network gateway or not

Type: bool

Possible Values: null

Default: false


### vpnType

Virtual network gateway vpn type

Type: string

Possible Values: ["RouteBased","PolicyBased"]

Default: RouteBased


### webServerType

Web server type

Type: string

Possible Values: ["apache","nginx"]

Default: apache


