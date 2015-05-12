# Create a SQL Server 2014 Always On Availability Group with PowerShell DSC Extension

This template will create a SQL Server 2014 Always On Availability Group using the PowerShell DSC Extension it creates the following resources:

+	A Virtual Network
+	A Storage Account
+	An external and an internal load balancer
+	Two VMs as Domain Controllers for a new Forest and Domain
+	Three VMs in a Windows Server Cluster, two VMs run SQL Server 2014 with a common availability group and the third is a File Share Witness for the Cluster
+	Two Availability Sets one for the AD VMs, the other for the SQL and Witness VMs, the second Availability Set is configured with three Update Domains and three Fault Domains

The external load balancer creates an RDP NAT rule to allow connectivity to the first VM created, in order to access other VMs in the deployment this VM should be used as a jumpbox.

There is an internal load balancer created, an always on listener is created using this load balancer.

There are a number of issues\workarounds in this template and the associated DSC Scripts:

1. This template is entirely serial due to some issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently.
2. Their is only one execution of a DSC configuration per VM for the same reasons.

Both of the issues will be fixed in the near future

Click the button below to deploy

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li><li>"Standard_ZRS"</li></ul> |
| deploymentLocation  | Location where to deploy the resource <br><ul>**Allowed Values**<li>West US</li><li>East US</li><li>**West Europe (default)**</li><li>East Asia</li><li>Southeast Asia</li>|
| virtualNetworkName | Name of the Virtual Network |
| virtualNetworkAddressRange | Virtual Network Address Range <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| staticSubnet | Address Range for a subnet that contains VMs with static IP addresses <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| sqlSubnet | Address Range for a subnet that contains the SQL and FSW VMs <br> <ul><li>10.0.1.0/24 **(default)**</li></ul> |
| adPDCNicIPAddress | The IP address of the new AD PDC  <br> <ul><li>**10.0.0.4 (default)**</li></ul> |
| adBDCNicIPAddress | The IP address of the new AD BDC  <br> <ul><li>**10.0.0.5 (default)**</li></ul> |
| SQLLBIPAddress | The IP address of the new ILB used for the SQL Listener <br> <ul><li>**10.0.0.6 (default)**</li></ul> |
| publicIPAddressType | Type of Public IP Address <br> <ul>**Allowed Values**<li>Dynamic **(default)**</li><li>Static</li></ul>|
| adVMPrefix | The prefix used for the AD VM names |
| sqlVMPrefix | The prefix used for the SQL Server and witness VM names |
| adminUsername | Admin username for the VM **This will also be used as the domain admin user name**|
| adminPassword | Admin password for the VM **This will also be used as the domain admin password and the SafeMode password** |
| adVMSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A0 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| sqlVMSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A3 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| witnessVMSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A0 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| adImageName | Name of image to use for the VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| sqlImageName | Name of image to use for the SQL VM <br> <ul><li>fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2048.0-Ent-ENU-Win2012R2-cy15su04 **(default)**</li></ul>|
| witnessImageName | Name of image to use for the VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| vmContainerName | The container name in the storage account where VM disks are stored|
| domainName | The FQDN of the AD Domain created |
| sqlServerServiceAccountUserName | The name of an account with is created to run the SQL Server Service |
| sqlServerServiceAccountPassword"| The SQL Server Service account password |
| RDPPort | The public RDP port for the First VM |
| dnsPrefix | The DNS prefix for the public IP address used by the Load Balancer |
| AssetLocation | The location of resources such as templates and DSC modules that the script is dependent <br> <ul><li> **https://raw.githubusercontent.com/azurermtemplates/azurermtemplates/master/sql-server-2014-alwayson-dsc (default)**</li></ul> |
| dataBaseNames | An array of database names. Each database will be created and added to the Always On Availability Group Created |



