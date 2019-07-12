# Azure Site Recovery Automation Runbooks

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fasr-automation-recovery%2F%2Fazuredeploy.json) 

This Resource Manager Template will deploy the following:

* Create or use an existing Azure Automation account
* Imports the following PowerShell Modules:
	* AzureRm.Profile
	* AzureRm.Compute
	* AzureRm.Network
	* AzureRm.Resources
	* AzureRm.Automation

* Automation runbooks for Azure Site Recovery, to be used together with Recovery Plans to simplify and streamline DR/Migration scenarios for you appliactions

### Pre-reqs

All the runbooks requires an **Azure RunAs Account** in the automation account. This can be created manually in the portal post deployment. 

### Automation Runbooks for Azure Site Recovery 

##### ASR-SQL-FailoverAG

This runbook fails over SQL Always On Availability Group inside an Azure virtual machine as part of failover/migration to **Azure**

**How to use this runbook**

1. Change the value of $Location in the runbook, with the region where SQL Always On Azure virtual machine is running.
2. Add this script as a **pre-action** of the first group of the recovery plan
3. Create a complex variable for the automation account using PowerShell.

Example: 
 
        $InputObject = @{"TestSQLVMName" = "#TestSQLVMName" ; "TestSQLVMRG" = "#TestSQLVMRG" ; "ProdSQLVMName" = "#ProdSQLVMName" ; "ProdSQLVMRG" = "#ProdSQLVMRG"; "Paths" = @{"1"="#sqlserver:\sql\sqlazureVM\default\availabilitygroups\ag1";"2"="#sqlserver:\sql\sqlazureVM\default\availabilitygroups\ag2"}}
        $RPDetails = New-Object -TypeName PSObject -Property $InputObject  | ConvertTo-Json
        New-AzureRmAutomationVariable -Name "#RecoveryPlanName" -ResourceGroupName "#AutomationAccountResourceGroup" -AutomationAccountName "#AutomationAccountName" -Value $RPDetails -Encrypted $false  

        Replace all strings starting with a '#' with appropriate value

##### ASR-DNS-UpdateIP

This runbook updates the DNS of virtual machines being failed over

**How to use this runbook**

1. Do a test failover of DNS virtual machine in the test network 
2. Change the value of $Location in the runbook, with the region where the Azure VMs will be running
3. Change the value of TestDNSVMName with the name of the DNS Azure virtual machine created in test network
4. Change the value of TestDNSVMRG with the name of the resource group of the DNS Azure virtual machine created in test network
5. Change the value of ProdDNSVMName with the name of the DNS Azure virtual machine in your Azure production network
6. Change the value of ProdDNSVMRG with the name of the resource group of the DNS Azure virtual machine created in production network
7. Add the runbook as a **post action** in a recovery plan group which has the virtual machines for which DNS has to be updated
8. Create a complex variable for the automation account using PowerShell

Example: 

		$InputObject = @{"#VMIdAsAvailableINASRVMProperties"=@{"Zone"="#ZoneFortheVirtualMachine";"VMName"="#HostNameofTheVirtualMachine"};"#VMIdAsAvailableINASRVMProperties2"=@{"Zone"="#ZoneFortheVirtualMachine2";"VMName"="#HostNameofTheVirtualMachine2"}}
        $RPDetails = New-Object -TypeName PSObject -Property $InputObject  | ConvertTo-Json
        New-AzureRmAutomationVariable -Name "#RecoveryPlanName" -ResourceGroupName "#AutomationAccountResourceGroup" -AutomationAccountName "#AutomationAccountName" -Value $RPDetails -Encrypted $false  

        Replace all strings starting with a '#' with appropriate value

##### ASR-AddSingleNSGPublicIp

This runbook will create a public IP address for the failed over VM - only in test failover

**How to use this runbook**

1. Give the name of the automation account in the variable $AutomationAccountName
2. Give the Resource Group name of the automation account in $AutomationAccountRg
3. Add this script as a post action in boot up group for the VMs where you need a public IP. 
4. If you want to use an NSG to the failed over VMs, then you must perform the following additional steps:
	1. Create the NSG in a Resource Group
	2. Create two new variables in the automation account (string variable), with the name of NSG and the NSG resource group, using this pattern:

			New-AzureRmAutomationVariable -ResourceGroupName <rg containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlanName>-NSG -Value <name of the NSG> -Encrypted $false

			New-AzureRmAutomationVariable -ResourceGroupName <rg containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlanName>-NSGRG -Value <name of the NSG resource group> -Encrypted $false

##### ASR-AddSingleLoadBalancer

This runbook will attach an existing load balancer to the vNics of the virtual machines in the recovery plan during failover

**How to use this runbook**

1. Ensure you have configured a backend pool for your existing load balancer
2. Add this script as a post action in boot up group where you need to associate the VMs with the existing Load Balancer
3. Create two new variables in the automation account with PowerShell, using the following pattern:

	        New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lb -Value <name of the load balancer> -Encrypted $false

            New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lbrg -Value <name of the load balancer resource group> -Encrypted $false     

##### ASR-AddMultipleLoadBalancers

This runbook will attach one or more load balancers to the vNics of the virtual machines, as part of failover.

**How to use this runbook**

1. Ensure you have configured a backend pool for your existing load balancer
2. Add this script as a post action in boot up group where you need to associate the VMs with the existing Load Balancer
3. Create a complex variable in the automation account using PowerShell, which will include the VMGUID for the protected VM(s), load balancer(s) name, and resource group(s) name containing the load balancer(s)

Example:

		$InputObject = @{"6949b3a9-ae82-5e90-882c-30e48dffdcd8"=@{"ResourceGroupName"="knlb";"LBName"="knextlb"};"6dce5d61-2416-546c-9bcd-c1bc79a5a678"=@{"ResourceGroupName"="knlb";"LBName"="knintlb"}}
        $RPDetails = New-Object -TypeName PSObject -Property $InputObject  | ConvertTo-Json
        New-AzureRmAutomationVariable -Name "#RecoveryPlanName" -ResourceGroupName "#AutomationAccountResourceGroup" -AutomationAccountName "#AutomationAccountName" -Value $RPDetails -Encrypted $false

		Replace all strings starting with a '#' with appropriate value  
      

##### ASR-AddPublicIp

This runbook will create a Public IP address for the failed over VM(s)

**How to use this runbook**

1. Add the runbook as a post action in boot up group containing the VMs, where you want to assign a public IP.

##### ASR-Wordpress-ChangeMysqlConfig

This runbook changes the WordPress configuration by replacing the wp-config.php and replace it with wp-config.php.Azure
This runbook uses an external powershellscript located at https://raw.githubusercontent.com/ruturaj/RecoveryPlanScripts/master/ChangeWPDBHostIP.ps1 and runs it inside all of the VMs of the group this script is added to.

**How to use this runbook**

1. Change the parameter $recoveryLocation to the region where VM is recovery to

#### Deploy to Azure

Click *Deploy to Azure* below to start the deployment

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fasr-automation-recovery%2F%2Fazuredeploy.json) 












