---
description: This template deploys storage for ORACLE deployments. Storage is provided using Azure NetApp Files, built on NetApp ONTAP storage OS.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: anf-oracle-storage
languages:
- bicep
- json
---
# ORACLE Azure NetApp Files storage

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-oracle/anf-oracle-storage/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-oracle%2Fanf-oracle-storage%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-oracle%2Fanf-oracle-storage%2Fazuredeploy.json)

This document covers the scenario of deploying storage for ORACLE deployments using an ORACLE storage template. Storage is provided using Azure NetApp Files, built on NetApp ONTAP storage OS.

[Azure NetApp Files application volume group for ORACLE is currently in preview](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-introduction).
You need to submit a waitlist request for accessing the feature through the [Azure NetApp Files application volume group for ORACLE waitlist submission page](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbR2Qj2eZL0mZPv1iKUrDGvc9UQzBDRUREOTc4MDdWREZaRzhOQzZGNTdFQiQlQCN0PWcu).
Wait for an official confirmation email from the Azure NetApp Files team before using application volume group for ORACLE.
## Planning your ORACLE deployment
Before you deploy ORACLE volumes using the application volume group, we recommend a thorough planning and sizing with the help of SAP and Azure NetApp Files specialists.
The decisions to make include the following:
* Define the network structure and delegated subnet. For details, see [Requirements and considerations](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#requirements-and-considerations).
* Size the ORACLE storage and VM requirements. You might need to increase the limits on the VMs and Azure NetApp Files to deploy ORACLE landscapes.
* Depending on the selected regions, you need to understand various technologies (for example, Zone, AvSet and PPG) to optimize you ORACLE deployment.
 For details, see:
  * [Azure proximity placement groups for optimal network latency with SAP applications](https://docs.microsoft.com/azure/virtual-machines/workloads/sap/sap-proximity-placement-scenarios)
  * [Deployment through Azure NetApp Files application volume group for ORACLE (AVG)](https://docs.microsoft.com/azure/virtual-machines/workloads/sap/oracle-vm-operations-netapp#deployment-through-azure-netapp-files-application-volume-group-for-oracle-avg)
  * [Best practices about proximity placement groups](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#best-practices-about-proximity-placement-groups) to understand different options on how to use PPG with the application volume group.

## Prerequisites
To use the application volume group ARM template, you need to prepare the following environment. As described in the links above, most implementations require a thorough planning and understanding of the various architectural differences. You need to manually prepare many of the steps as a one-time activity before provisioning the Azure NetApp Files volumes for ORACLE.

The prerequisite steps include:

1. **Networking**:
You need to decide on the networking architecture. To use Azure NetApp Files, you need to create a VNet.
Within the VNet, you need a delegated subnet where the Azure NetApp Files storage endpoints (IPs) will be placed.
To ensure that the size of this subnet is large enough, see [Considerations about delegating a subnet to Azure NetApp Files](https://docs.microsoft.com/azure/azure-netapp-files/azure-netapp-files-delegate-subnet#considerations).
   * Create a VNet.
   * Create the VM subnet and delegated subnet for Azure NetApp Files.

2. **NetApp account and capacity pool**:
A NetApp account (storage account) is the entry point for using Azure NetApp Files storage. You need to create at least one NetApp account. A capacity pool within the NetApp account is the logical unit where volumes are created.  The application volume group needs to use a manual QoS capacity pool, and the pool needs to have a size and service level that meet your ORACLE requirements. (You can resize a capacity pool at any time.)
   * Create a NetApp account.
   * Create a manual QoS capacity pool.

3. **Create the AvSet and PPG**:
For production landscapes, we recommend using a AvSet that is manually pinned to a data center where Azure NetApp Files resources are available in proximity. AvSet pinning ensures that VMs will not be moved on restart.
You need to assign the PPG to the AvSet. The PPG helps the application volume group find the closest Azure NetApp Files hardware. For details, see [Best practices about proximity placement groups](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#best-practices-about-proximity-placement-groups).
   * Create the AvSet,
   * Create the PPG,
   * Assign the PPG to the AvSet,

4. **Manually request AvSet pinning**.
AvSet pinning is required for long-term SAP HANA systems. Microsoft capacity planning team ensures that the required VMs for SAP HANA and Azure NetApp Files resources in proximity to the VMs are available. It also ensures that the VMs will not move on restart.
   * Use the SAP HANA VM Pinning Requirements Form (https://aka.ms/HANAPINNING) to request pinning.

5. **Create and start HANA DB VM**:
Before you can create volumes using the application volume group, you must anchor the PPG. This means you must create at least one VM using the pinned AvSet. After this VM is started, the PPG can be used to detect where the VM is running (anchored).
   * Create and start the VM using the AvSet.

After the above preparation, you can use the application volume group template to create volumes. Steps #3, #4 and #5 are not required if AvailabilityZone option selected.

## Automated prerequisite template

The steps in the prerequisite template include:

* Create a VNet.
* Create a NetApp account
* Create a capacity pool.

Note the following considerations:
* You can use this setup to test workflows or as a temporary ORACLE setup. However, you should not use it for long-term, production systems.
* This simplified process will work in many regions with AvailabiltyZone. However, there’s no guarantee that the proximity of ORACLE VMs and Azure NetApp Files hardware would work in all regions without manual pinning.

## Input Parameters
ORACLE Storage Template

|    | **Input Params**                                     | **Example**    | **Default**              | **Data Type Constrain** | **Comment (This will be shown as a tool tip)**                                                                                                                 	  		|
|----|------------------------------------------------------|----------------|--------------------------|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Unique System ID                                     | DEV            |  ORA                     | string of min len 3     | System ID for Oracle to create unique volume group and volume names. Minimum 3 and maximum 12 characters.                                                      	  		|
| 2  | Availability Zone                                    | 1              |                          | List None,1,2,3         | Availability Zone. This is None when proximity placement group is selected.                                                                                    	  		|
| 3  | Proximity Placement Group Name                       | ppg            |                          | string                  | Name of proximity placement group. This is optional when Availability Zone is selected.                                                                        	  		|
| 4  | Proximity Placement Group Resource Group Name        | ppg-rg         |                          | string                  | Resource group name for the proximity placement group. This is optional when Availability Zone is selected.                                                    	  		|
| 5  | Network Features                                     | Basic          | Standard                 | string                  | Basic or Standard network features available to the volume.                                                                                                    	  		|
| 6  | LDAP Eanbled                                         | true           | false                    | bool                    | Specifies whether LDAP is enabled or not for all the volumes.                                                                                                  	  		|
| 8  | No Of Oracle Data Volumes                            | 1              | 1                        | Integer >= 0            | Number of Oracle data volumes. Minimum 1 and maximum 8 data volumes.                                       								  		|
| 9  | Oracle DBSize In Tebibytes                           | 100            |                          | 800 >= Integer >= 1     | Total size of the database. This and the number of data volumes and addition capacity for snapshots will be used to calculate the size of each individual data volume.		|
| 10 | Oracle Throughput In Mebibytes Per Second            | 800            |                          | string of min len 1     | Total throughput in MiB/s for the database. This will be used to calculate the throughput of each data volume.	  								|
| 11 | AdditionalCapacityForSnapshotsPercentage             | 50             | 20                       | 100 >= Integer >= 0     | Additional capacity provisioned for each data volume to keep local snapshots. Possible values 0% - 100%. The default of 20% is usually sufficient to retain multiple snapshots.	|
| 12 | Tag Key                                              |                |                          | string                  | If a Tag Key is specified, it will be added to each volume created by this ARM template.                                                                       	  	   	|
| 13 | Tag Value                                            |                |                          | string                  | If a Tag Value is specified, it will be added to each volume created by this ARM template. The value will only be added if Tag Key was specified.              	  		|
| 14 | Azure Netapp Files Location                          | eastus         | resourceGroup().location | string of min len 1     | Azure NetApp Files (ANF) Location. If the resource group location is different than ANF location, ANF location needs to be specified.                          	  		|
| 15 | Azure Netapp Files                                   | anf-name       |                          | string of min len 1     | Name of Azure NetApp Files (ANF) account.                                                                                                                      	  		|
| 16 | Virtual Network                                      | vnet-name      |                          | string of min len 1     | Virtual Network name for the subnet.                                                                                                                           	  		|
| 17 | Delegated Subnet                                     | subnet-name    |                          | string of min len 1     | Delegated Subnet name.                                                                                                                                         	  		|
| 18 | Data Size In Gibibytes                               | auto/100       | auto                     | string of min len 1     | Manually specify the size of each data volume or use “auto” to let ARM calculate. See documentation for details.                                                    	  	|
| 19 | Data Performance In Mebibytes Per Second             | auto/64        | auto                     | string of min len 1     | Manually specify the performance of each data volume or use “auto” to let ARM calculate. See documentation for details.                                            	  		|
| 20 | Log Size In Gibibytes                                | auto/100       | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto" or integer values (min 100 GiB) representing size.                                                    	  		|
| 21 | Log Performance In Mebibytes Per Second              | auto/150       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                            	  		|
| 22 | Log Mirror Size In Gibibytes                         | auto/none/100  | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size.                                              	  		|
| 23 | Log Mirror Performance In Mebibytes Per Second       | auto/150       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                            	  		|
| 24 | Binary Size In Gibibytes                             | auto/none/100  | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size.                                              	  		|
| 25 | Binary Performance In Mebibytes Per Second           | auto/64        | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                            	  		|
| 26 | Backup Size In Gibibytes                             | auto/none/100  | auto                     | string of min len 1     | Volume that can serve as the fast recovery area (FRA) to store archive logs and backups.                                             	  					|
| 27 | Backup Performance In Mebibytes Per Second           | auto/150       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                            	  		|
| 28 | Data, Log, LogMirror, Binary and Backup NFS Version  | NFSv3          | NFSv4.1                  | List NFSv3, NFSv4.1     | NFS Protocol version for all the volumes.                                              |

## Volume Naming Convention
Following input attributes are used to generate volume name. Volume name and mount point are same.
* SID
* Prefix

|**Attributes**                                                            | **Naming convention**                                                                                                                                                                                                                                                                            |
|--------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <ul><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li><li>SID</li></ul> | <ul><li>Data1 volume: &lt;SID&gt;-ora-data1</li><li>Data2 volume: &lt;SID&gt;-ora-data2</li><li>Data3 volume: &lt;SID&gt;-ora-data3</li><li>Data4 volume: &lt;SID&gt;-ora-data4</li><li>Data5 volume: &lt;SID&gt;-ora-data5</li><li>Data6 volume: &lt;SID&gt;-ora-data6</li><li>Data7 volume: &lt;SID&gt;-ora-data7</li><li>Data8 volume: &lt;SID&gt;-ora-data8</li><li>Log volume:&lt;SID&gt;-ora-log</li><li>Log Mirror volume:&lt;SID&gt;-ora-log-mirror</li><li>Binary volume:&lt;SID&gt;-ora-binary</li><li>Backup volume:&lt;SID&gt;-ora-backup</li></ul>                                                             |

## Volume Size/Throughput auto computation
Following attributes plays role in deciding volume size and throughput, if selected as auto.
* Oracle database size (OracleDatabaseSize (inTB))
* AdditionalCapacityForSnapshotsPercentage (AdditionalCapacityForSnapshotsPercentagePerVolume)
* No of Oracle data volumes (NoOfOracleDataVolumes)
* Oracle throughput(OracleThroughput (MB/s))

### Size (in GiB)
| **Volume Type**   | **Value**                                                                      				 				 	     | **Remarks**                           |
|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------|
| Data (1 -8)       | Min(100TiB, OracleDataBaseSize/NoOfOracleDataVolumes + (AdditionalCapacityForSnapshotsPercentage/100 * (OracleDataBaseSize/NoOfOracleDataVolumes)))GiB | Minimum volume size on ANF is 100GiB  |
| Log               | 100GiB                                          											         	     | Minimum volume size on ANF is 100GiB  |
| Log Mirror        | 100GiB                                          											     	             | Minimum volume size on ANF is 100GiB  |
| Binary            | 100GiB                                          											                     | Minimum volume size on ANF is 100GiB  |
| Backup            | Min(100TiB,OracleDataBaseSize/2)GiB 	 				 									     | Minimum volume size on ANF is 100GiB  |

### Throughput (MiB/s)
| **Volume Type**   | **Value**                               |
|-------------------|---------------------------------------- |
| Data (1 -8)       | OracleThroughput/NoOfOracleDataVolumes  |
| Log               | 150                                     |
| Log Miror         | 150                                     |
| Binary            | 64                                      |
| Backup            | 150                                     |

## Volume Accessibility
Volumes can be accessed over NFS protocol, the mount path will be the same as the volume name. Each volume will have an export policy comprised of multiple rules.
A rule can have allowedClients, ruleIndex, unixReadOnly, unixReadWrite, nfsv3 and nfsv41 as attributes. Each volume created will have a default rule attached as default and will be as follows.

| **Attributes** | **Value** | **Description**                                                                                        | **Remark**                                                                   |
|----------------|-----------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| allowedClients | 0.0.0.0/0 | Allowed clients specified in CIDR format                                                               |                                                                              |
| ruleIndex      | 1         | Specify Priority                                                                                       |                                                                              |
| unixReadOnly   | false     | Read Only                                                                                              |                                                                              |
| unixReadWrite  | true      | Read & Write                                                                                           |                                                                              |
| nfsv3          | false     | Version for NFS protocol. This attribute should be common for all export policies.                     | All oracle volumes the value will be chosen as part of Input Parameters.     |
| nfsv41         | true      | Version for NFS protocol (default is nfsv41). This attribute should be common for all export policies. | All oracle volumes the value will be chosen as part of Input Parameters.     |

`Tags: Microsoft.NetApp/netAppAccounts/volumeGroups, Microsoft.Network/virtualNetworks, Microsoft.NetApp/netAppAccounts, Microsoft.NetApp/netAppAccounts/capacityPools`
