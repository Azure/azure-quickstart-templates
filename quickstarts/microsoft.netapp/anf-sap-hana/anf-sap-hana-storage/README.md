---
description: This template deploys storage for SAP HANA deployments. Storage is provided using Azure NetApp Files, built on NetApp ONTAP storage OS.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: anf-sap-hana-storage
languages:
- json
---
# SAP HANA Azure NetApp Files storage

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-sap-hana/anf-sap-hana-storage/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-sap-hana%2Fanf-sap-hana-storage%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-sap-hana%2Fanf-sap-hana-storage%2Fazuredeploy.json)

This document covers the scenario of deploying storage for SAP HANA deployments using a SAP HANA storage template. Storage is provided using Azure NetApp Files, built on NetApp ONTAP storage OS.

[Azure NetApp Files application volume group for SAP HANA is currently in preview](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-introduction).
You need to submit a waitlist request for accessing the feature through the [Azure NetApp Files application volume group for SAP HANA waitlist submission page](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbR2Qj2eZL0mZPv1iKUrDGvc9UQzBDRUREOTc4MDdWREZaRzhOQzZGNTdFQiQlQCN0PWcu).
Wait for an official confirmation email from the Azure NetApp Files team before using application volume group for SAP HANA.
## Planning your SAP HANA deployment
Before you deploy HANA volumes using the application volume group, we recommend a thorough planning and sizing with the help of SAP and Azure NetApp Files specialists.
The decisions to make include the following:
* Define the network structure and delegated subnet. For details, see [Requirements and considerations](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#requirements-and-considerations).
* Size the SAP HANA storage and VM requirements. You might need to increase the limits on the VMs and Azure NetApp Files to deploy SAP HANA landscapes.
* Depending on the selected regions, you need to understand various technologies (for example, AvSet and PPG) to optimize you SAP HANA deployment.
 For details, see:
  * [Azure proximity placement groups for optimal network latency with SAP applications](https://docs.microsoft.com/azure/virtual-machines/workloads/sap/sap-proximity-placement-scenarios)
  * [Deployment through Azure NetApp Files application volume group for SAP HANA (AVG)](https://docs.microsoft.com/azure/virtual-machines/workloads/sap/hana-vm-operations-netapp#deployment-through-azure-netapp-files-application-volume-group-for-sap-hana-avg)
  * [Best practices about proximity placement groups](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#best-practices-about-proximity-placement-groups) to understand different options on how to use PPG with the application volume group.

## Prerequisites
To use the application volume group ARM template, you need to prepare the following environment. As described in the links above, most implementations require a thorough planning and understanding of the various architectural differences. You need to manually prepare many of the steps as a one-time activity before provisioning the Azure NetApp Files volumes for SAP HANA.

The prerequisite steps include:

1. **Networking**:
You need to decide on the networking architecture. To use Azure NetApp Files, you need to create a VNet.
Within the VNet, you need a delegated subnet where the Azure NetApp Files storage endpoints (IPs) will be placed.
To ensure that the size of this subnet is large enough, see [Considerations about delegating a subnet to Azure NetApp Files](https://docs.microsoft.com/azure/azure-netapp-files/azure-netapp-files-delegate-subnet#considerations).
   * Create a VNet.
   * Create the VM subnet and delegated subnet for Azure NetApp Files.

2. **NetApp account and capacity pool**:
A NetApp account (storage account) is the entry point for using Azure NetApp Files storage. You need to create at least one NetApp account. A capacity pool within the NetApp account is the logical unit where volumes are created.  The application volume group needs to use a manual QoS capacity pool, and the pool needs to have a size and service level that meet your HANA requirements. (You can resize a capacity pool at any time.)
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

After the above preparation, you can use the application volume group template to create volumes.

## Automated prerequisite template

As mentioned above, a long-term SAP HANA landscape requires a thorough planning and most probably a manual creation of all the prerequisites. This GitHub document includes a prerequisite template that automates all required steps without manual pinning. As described in [Best practices about proximity placement groups],(https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-considerations#best-practices-about-proximity-placement-groups) this simplified process is based on the fact that, in many regions, the VM type used for SAP HANA (Mv2 series) is collocated with the Azure NetApp Files hardware. As such, manual pinning can be skipped.

The steps in the prerequisite template include:

* Create a VNet.
* Create a NetApp account
* Create a capacity pool.
* Create a PPG.
* Create a AvSet.
* Create a VM (M-Series) with the PPG assigned in the VNet.

These steps make a PPG available and anchored to the M-Series VM. This PPG can be used by the ARM template to provision volumes for SAP HANA.

Note the following considerations:
* You can use this setup to test workflows or as a temporary HANA setup. However, you should not use it for long-term, production systems.
* This simplified process will work in many regions. However, there’s no guarantee that the proximity of HANA VMs and Azure NetApp Files hardware would work in all regions without manual pinning.

## Input Parameters
SAP HANA Storage Template

|    | **Input Params**                                     | **Example**    | **Default**              | **Data Type Constrain** | **Comment (This will be shown as a tool tip)**                                                                                                                                                                                                                                                                            |
|----|------------------------------------------------------|----------------|--------------------------|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | SAP System ID                                        | DEV            |                          | string of length 3      | SAP system ID (Three characters long alpha-numeric string).                                                                                                                                                                                                                                                               |
| 2  | Proximity Placement Group Name                       | ppg            |                          | string of min len 1     | Name of proximity placement group.                                                                                                                                                                                                                                                                                        |
| 3  | Proximity Placement Group Resource Group Name        | ppg-rg         |                          | string of min len 1     |  Resource group name for the proximity placement group.                                                                                                                                                                                                                                                        |
| 4  | SAP Memory In Gibibytes                              | 100            |                          | 12000 >= Integer >= 1   | SAP HANA memory (in GiB max supported 12000 GiB), used to auto compute storage size and throughput.                                                                                                                                                                                                                       |
| 5  | Additional Capacity For Snapshots Percentage Of RAM) | 50             | 50                       | 200 >= Integer >= 0     | Additional memory to store snapshots, must be specified as % of RAM (range 0-200). This is used to auto compute storage size.                                                                                                                                                                                             |
| 6  | Starting SAP Host ID                                 | 1              | 1                        | Integer >= 1            | Starting SAP HANA Host ID. Host ID 1 indicates Master Host. Shared, Data Backup and Log Backup volumes are only provisioned for Master Host.                                                                                                                                                                              |
| 7  | Number Of SAP Hosts                                  | 2              | 1                        | 3 >= Integer >= 1       | Total Number of SAP HANA hosts in this deployment (currently max 3 nodes can be configured).                                                                                                                                                                                                                              |
| 8  | System Role                                          | PRIMARY        | PRIMARY                  | PRIMARY, HA             | Type of role for the storage account. Primary indicates first of a SAP HANA Replication (HSR) setup or No HSR. High Availability (HA) specifies volumes for the secondary host using HSR.                                                                                                                                 |
| 9  | Prefix                                               | default        | default                  | default or “TEXT-“      | All volume names will be prefixed with the given text. The default values for prefix text depends on system role. For PRIMARY it will be "" and for HA it will be "HA-".                                                                                                                                                  |
| 10  | Tag Key                                              |                |                          | string                  | If a Tag Key is specified, it will be added to each volume created by this ARM template. It is recommended to add a tag for HSR deployments, with the tag name as "HSRPartnerStorageResourceId".                                                                                                                          |
| 11 | Tag Value                                            |                |                          | string                  | If a Tag Value is specified, it will be added to each volume created by this ARM template. The value will only be added if Tag Key was specified. It is recommended to add a tag for HSR deployments, with Tag Value as "Please enter the peering partner Volume ID" and later update it for each volume from the ANF UI. |
| 12 | Azure Netapp Files Location                          | eastus         | resourceGroup().location | string of min len 1     | Azure NetApp Files (ANF) Location. If the resource group location is different than ANF location, ANF location needs to be specified.                                                                                                                                                                                     |
| 13 | Azure Netapp Files                                   | anf-name       |                          | string of min len 1     | Name of Azure NetApp Files (ANF) account.                                                                                                                                                                                                                                                                                 |
| 14 | Capacity Pool                                        | cp-name        |                          | string of min len 1     | Name of Capacity Pool in Azure NetApp Files (ANF) account. All the volumes are created using this capacity pool.                                                                                                                                                                                                          |
| 15 | Virtual Network                                      | vnet-name      |                          | string of min len 1     | Virtual Network name for the subnet.                                                                                                                                                                                                                                                                                      |
| 16 | Delegated Subnet                                     | subnet-name    |                          | string of min len 1     | Delegated Subnet name.                                                                                                                                                                                                                                                                                                    |
| 17 | Data Size In Gibibytes                               | auto/1024      | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto" or integer values (min 100 GiB) representing size.                                                                                                                                                                                                               |
| 18 | Data Performance In Mebibytes Per Second             | auto/450       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                                                                                                                                                                                       |
| 19 | Log Size In Gibibytes                                | auto/500       | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto" or integer values (min 100 GiB) representing size.                                                                                                                                                                                                               |
| 20 | Log Performance In Mebibytes Per Second              | auto/250       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                                                                                                                                                                                       |
| 21 | Shared Size In Gibibytes                             | auto/none/1024 | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size. The values are only considered if SAP HANA Host ID is 1, in other cases shared storage is not deployed.                                                                                                 |
| 22 | Shared Performance In Mebibytes Per Second           | auto/64        | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                                                                                                                                                                                       |
| 23 | Data Backup And Log Backup NFS Version               | NFSv3          | NFSv4.1                  | List NFSv3, NFSv4.1     | NFS Protocol version for data backup and log backup volumes. This option is common for the two volumes.                                                                                                                                                                                                                   |
| 24 | Data Backup Size In Gibibytes                        | auto/none/100  | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size. The values are only considered if SAP HANA Host ID is 1, in other cases data backup storage is not deployed.                                                                                            |
| 25 | Data Backup Performance In Mebibytes Per Second      | auto/250       | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                                                                                                                                                                                       |
| 26 | Log Backup Size In Gibibytes                         | auto/none/100  | auto                     | string of min len 1     | Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size. The values are only considered if SAP HANA Host ID is 1, in other cases log backup storage is not deployed.                                                                                             |
| 27 | Log Backup Performance In Mebibytes Per Second       | auto/64        | auto                     | string of min len 1     | Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.                                                                                                                                                                                                       |

## WorkFlow Scenario
### SAP HANA single-host system
The storage template can be used to create SAP HANA system by setting Starting Host ID to 1, HANA System Role as PRIMARY and Prefix as default. To extend it to a multiple-host system, the volume size has to be increased manually from the volume modification Web portal GUI.
For further details refer [here](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-deploy-first-host).

### SAP HANA multiple-host system
The storage template can be used to create SAP HANA multiple-host system by setting HANA System Role as PRIMARY and Prefix as default. For N worker hosts of the SAP HANA multiple-host cluster a data and log volume will be created. For an N host SAP HANA cluster, the user needs to specify Starting SAP Host ID as 1 and Number of SAP Host as N.
For further details refer [here](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-add-hosts).

### SAP HANA System Replication (HSR)
HANA System Replication will require two (identical) SAP HANA systems that replicate on the application level. HSR must be configured after installation of the SAP HANA instance (single-host as well as for multiple-host system). HSR can be used within the same region to facilitate a HA scenario. It makes sense to split this scenario into two workflows.
1. Use single-host system or multiple-host system workflow to create the primary instance volumes in PPG. (HANA System Role as PRIMARY)
2. Use single-host system or multiple-host system workflow to create the secondary instance volumes.
For HA: In same DZ/same or different PPG (HANA System Role as HA and Prefix default).

For further details refer [here](https://docs.microsoft.com/azure/azure-netapp-files/application-volume-group-add-volume-secondary).

## Volume Naming Convention
Following input attributes are used to generate volume name. Volume name and mount point are same.
* SID
* Starting SAP Host ID
* Number of SAP Host
* System Role
* Prefix

|**Scenario**   | **Attributes**                                                            | **Naming convention**                                                                                                                                                                                                                                                                            | **Remarks**                                                                                                                                                                                                                                       |
|---------------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Single-host   | <ul><li>SID</li><li>1</li><li>1</li><li>PRIMARY</li><li>default</li></ul> | <ul><li>Data volume: &lt;SID&gt;-data-mnt00001</li><li>Log volume:&lt;SID&gt;-log-mnt00001</li><li>Shared volume:&lt;SID&gt;-shared</li><li>Log backup:&lt;SID&gt;-log-backup </li><li>Data backup:&lt;SID&gt;-data-backup</li></ul>                                                             |                                                                                                                                                                                                                                                   |
| Multiple-host | <ul><li>SID</li><li>1</li><li>N</li><li>PRIMARY</li><li>default</li></ul> | <ul><li>Data volume: &lt;SID&gt;-data-mnt00001,...,&lt;SID&gt;-data-mnt0000N</li><li>Log volume:&lt;SID&gt;-log-mnt00001,....,&lt;SID&gt;-log-mnt0000N</li><li>Shared volume:&lt;SID&gt;-shared</li><li>Log backup:&lt;SID&gt;-log-backup </li><li>Data backup:&lt;SID&gt;-data-backup</li></ul> | N is the number of hosts in deployment. </br> Note: Shared, Log backup and Data backup only created for HostID==1.                                                                                                                                |
| HSR           | <ul><li>SID</li><li>1</li><li>1</li><li>HA</li><li>default</li></ul>      | Secondary:</br><ul><li>Data volume: HA-&lt;SID&gt;-data-mnt00001</li><li>Log volume: HA-&lt;SID&gt;-log-mnt00001</li><li>Shared volume: HA-&lt;SID&gt;-shared</li><li>Log backup: HA-&lt;SID&gt;-log-backup</li><li>Data backup: HA-&lt;SID&gt;-data-backup</li></ul>                            | Primary:</br> <ul><li>Data volume: &lt;SID&gt;-data-mnt00001</li><li>Log volume:&lt;SID&gt;-log-mnt00001</li><li>Shared volume:&lt;SID&gt;-shared</li><li>Log backup:&lt;SID&gt;-log-backup </li><li>Data backup:&lt;SID&gt;-data-backup</li></ul>|

## Volume Size/Throughput auto computation
Following attributes plays role in deciding volume size and throughput, if selected as auto.
* SAP HANA Memory (in GiB)  (Memory)
* Additional Capacity for Snapshots (% of RAM) (AdditionalCapacityForSnapshotsPercentage)
* Number of SAP Host (TotalNumberofSAPHANAHosts)

### Size (in GiB)
| **Volume Type** | **Value**                                                                      | **Remarks**                                                                                                                                                                                                                                                                                                                                                                                                   |
|-----------------|--------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Data            | Max(100GiB, (Memory + (AdditionalCapacityForSnapshotsPercentage * Memory)))GiB | Minimum volume size on ANF is 100GiB                                                                                                                                                                                                                                                                                                                                                                          |
| Log             | Max(100GiB , Min(512,(0.5*Memory))GiB                                          | SAP specifies the following minimal values: </br><ul><li>Systems with RAM < 512 GiB : 50% of RAM</li><li>Systems with RAM > 512 GiB : 512 GiB </li></ul>Note: Minimum volume size on ANF is 100GiB                                                                                                                                                                                                            |
| Shared          | Max(1TiB, (int((TotalNumberofSAPHANAHosts+3)/4)) * Memory)GiB                  | The actual size depends on total number of hosts. If a single-host system is extended to a multiple-host system later, the user needs to manually resize it. The auto option will give the recommended size for TotalNumberofSAPHANAHosts hosts cluster. SAP HANA recommendation for the sizes are as follows: <\br> Size = (int((TotalNumberofSAPHANAHosts+3)/4)) * Memory </br> Note: Minimum Value is 1TiB |
| Data Backup     | Max(100GiB, sum(data.size, log.size))GiB	                                   |                                                                                                                                                                                                                                                                                                                                                                                                               |
| Log Backup      | 512GiB                                                                         | Recommended size 512GiB                                                                                                                                                                                                                                                                                                                                                                                       |

### Throughput (MiB/s)
| **Volume Type** | **Value**                                                                                                                                                                                                                                                                                                                                                                                                                                                   | **Remarks**                                                                                                                                                                                        |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Data            | <table><tr><td colspan="2">**Memory Range (in TiB)**</td><td rowspan="2">**Function Value**</td></tr><tr><td>**Min**</td><td>**Max**</td></tr><tr><td>0</td><td>1</td><td>400</td></tr><tr><td>1</td><td>2</td><td>600</td></tr><tr><td>2</td><td>4</td><td>800</td></tr><tr><td>4</td><td>6</td><td>1000</td></tr><tr><td>6</td><td>8</td><td>1200</td></tr><tr><td>8</td><td>10</td><td>1400</td></tr><tr><td>10</td><td>∞</td><td>1500</td></tr></table> |                                                                                                                                                                 |
| Log             | <table><tr><td colspan="2">**Memory Range (in TiB)**</td><td rowspan="2">**Function Value**</td></tr><tr><td>**Min**</td><td>**Max**</td></tr><tr><td>0</td><td>4</td><td>250</td></tr><tr><td>0</td><td>∞</td><td>500</td></tr></table>                                                                                                                                                                                                                    |                                                                                                                                                                 |
| Shared          | 64                                                                                                                                                                                                                                                                                                                                                                                                                                                          | In multiple-host systems, since all hosts are accessing the volume this will be (64MiB x number of hosts), with a maximum limit of 250MiB/s for 4 or more hosts |
| Data Backup     | 128                                                                                                                                                                                                                                                                                                                                                                                                                                                         | 128 - 512 MiB/s for each host. Hard to predict Auto, if we add only one host at a time and backup volumes on first host only                                    |
| Log Backup      | 250                                                                                                                                                                                                                                                                                                                                                                                                                                                         | 250 MiB/s for LOG volume to ensure that under high load data backup can happen.                                                                                 |

## Volume Accessibility
Volumes can be accessed over NFS protocol, the mount path will be the same as the volume name. Each volume will have an export policy comprised of multiple rules.
A rule can have allowedClients, ruleIndex, unixReadOnly, unixReadWrite, nfsv3 and nfsv41 as attributes. Each volume created will have a default rule attached as default and will be as follows.

| **Attributes** | **Value** | **Description**                                                                                        | **Remark**                                                                                                                                                         |
|----------------|-----------|--------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| allowedClients | 0.0.0.0/0 | Allowed clients specified in CIDR format                                                               |                                                                                                                                                                    |
| ruleIndex      | 1         | Specify Priority                                                                                       |                                                                                                                                                                    |
| unixReadOnly   | false     | Read Only                                                                                              |                                                                                                                                                                    |
| unixReadWrite  | true      | Read & Write                                                                                           |                                                                                                                                                                    |
| nfsv3          | false     | Version for NFS protocol. This attribute should be common for all export policies.                     | For Data backup and Log backup volumes the value will be chosen as part of Input Parameters. However, for data, log and shared volume values will be always false. |
| nfsv41         | true      | Version for NFS protocol (default is nfsv41). This attribute should be common for all export policies. | For Data backup and Log backup volumes the value will be chosen as part of Input Parameters. However, for data, log and shared volume value will be always true.   |

Note: For Data backup and Log backup volumes, user will have an option to choose between nfsv3 or nfsv41. However, for Data, Log and Shared volume default will be nfsv41.
`Tags: Microsoft.NetApp/netAppAccounts/volumeGroups, Microsoft.Network/virtualNetworks, Microsoft.NetApp/netAppAccounts, Microsoft.NetApp/netAppAccounts/capacityPools, Microsoft.Compute/proximityPlacementGroups, Microsoft.Compute/availabilitySets, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
