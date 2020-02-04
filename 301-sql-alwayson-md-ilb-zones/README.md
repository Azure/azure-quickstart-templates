# Create a SQL Server AlwaysOn Availability Group in an existing Azure VNET and Active Directory domain across Availability Zones using an Internal Load Balancer

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/PublicLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/PublicDeployment.svg" />&nbsp;

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/FairfaxLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/FairfaxDeployment.svg" />&nbsp;
    
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/BestPracticeResult.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-sql-alwayson-md-ilb-zones/CredScanResult.svg" />&nbsp;
    
    
    <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-sql-alwayson-md-ilb-zones%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
    </a>
    <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-sql-alwayson-md-ilb-zones%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
    </a>
    
    *Tests executed on 11/18/2019 show this template is working fine on Azure Public, despite the status of the above badges. You need to provision an AD domain and a virtual network with correct DSN resolution for domain names.*

This template will create a SQL Server AlwaysOn Availability Group using the PowerShell DSC Extension in an existing Azure Virtual Network and Active Directory environment. Both SQL Server 2016 and SQL Server 2017 are supported by this template. The SQL Server VMs will be provisioned across multiple Azure Availability Zones and requests will be directed to the Listener using the Internal Load Balancer (ILB) Standard.

## Deploying Sample Templates

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

Tags: ``cluster, ha, sql, sql server 2016, sql server 2017, alwayson, availability zones``
