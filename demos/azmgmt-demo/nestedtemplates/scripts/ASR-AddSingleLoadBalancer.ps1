<# 
    .DESCRIPTION 
        This runbook will attach an existing load balancer to the vNics of the virtual machines, in the Recovery Plan during failover. 
         
        This will create a Public IP address for the failed over VM(s). 
         
        Pre-requisites 
        All resources involved are based on Azure Resource Manager (NOT Azure Classic)

        - A Load Balancer with a backend pool
        - Automation variables for the Load Balancer name, and the Resource Group containing the Load Balancer

        To create the variables and use it towards multiple recovery plans, you should follow this pattern:
            
            New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lb -Value <name of the load balancer> -Encrypted $false

            New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lbrg -Value <name of the load balancer resource group> -Encrypted $false           

        The following AzureRm Modules are required
        - AzureRm.Profile
        - AzureRm.Resources
        - AzureRm.Compute
        - AzureRm.Network          
         
        How to add the script? 
        Add this script as a post action in boot up group where you need to associate the VMs with the existing Load Balancer                
 
    .NOTES 
        AUTHOR: krnese@microsoft.com - AzureCAT
        LASTEDIT: 20 March, 2017 
#> 
param ( 
        [Object]$RecoveryPlanContext 
      ) 

Write-output $RecoveryPlanContext

# Set Error Preference	

$ErrorActionPreference = "Stop"

if ($RecoveryPlanContext.FailoverDirection -ne "PrimaryToSecondary") 
    {
        Write-Output "Failover Direction is not Azure, and the script will stop."
    }
else {
        $VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name
        Write-Output ("Found the following VMGuid(s): `n" + $VMInfo)
            if ($VMInfo -is [system.array])
            {
                $VMinfo = $VMinfo[0]
                Write-Output "Found multiple VMs in the Recovery Plan"
            }
            else
            {
                Write-Output "Found only a single VM in the Recovery Plan"
            }
Try 
 {
    #Logging in to Azure...

    "Logging in to Azure..."
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
     Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    "Selecting Azure subscription..."
    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
 }
Catch
 {
      $ErrorMessage = 'Login to Azure subscription failed.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
 }
Try
 {
    $LBNameVariable = $RecoveryPlanContext.RecoveryPlanName + "-LB"    
    $LBRgVariable = $RecoveryPlanContext.RecoveryPlanName + "-LBRG"    
    $LBName = Get-AutomationVariable -Name $LBNameVariable    
    $LBRgName = Get-AutomationVariable -Name $LBRgVariable
    $LoadBalancer = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $LBRgName        
 }
Catch
 {
    $ErrorMessage = 'Failed to retrieve Load Balancer info from Automation variables.'
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $_
    Write-Error -Message $ErrorMessage `
                   -ErrorAction Stop
 }
    #Getting VM details from the Recovery Plan Group, and associate the vNics with the Load Balancer
Try
 {
    $VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name
    $VMs = $RecoveryPlanContext.VmMap
    $vmMap = $RecoveryPlanContext.VmMap
    foreach ($VMID in $VMinfo)
    {
        $VM = $vmMap.$VMID
        Write-Output $VM.ResourceGroupName
        Write-Output $VM.RoleName    
        $AzureVm = Get-AzureRmVm -ResourceGroupName $VM.ResourceGroupName -Name $VM.RoleName    
        If ($AzureVm.AvailabilitySetReference -eq $null)
        {
            Write-Output "No Availability Set is present for VM: `n" $AzureVm.Name
        }
        else
        {
            Write-Output "Availability Set is present for VM: `n" $AzureVm.Name
        }
        #Join the VMs NICs to backend pool of the Load Balancer
        $ARMNic = Get-AzureRmResource -ResourceId $AzureVm.NetworkInterfaceIDs[0]
        $Nic = Get-AzureRmNetworkInterface -Name $ARMNic.Name -ResourceGroupName $ARMNic.ResourceGroupName
        $Nic.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($LoadBalancer.BackendAddressPools[0]);        
        $Nic | Set-AzureRmNetworkInterface    
        Write-Output "Done configuring Load Balancing for VM" $AzureVm.Name    
    }
 }
Catch
 {
    $ErrorMessage = 'Failed to associate the VM with the Load Balancer.'
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $_
    Write-Error -Message $ErrorMessage `
                   -ErrorAction Stop
 }
}