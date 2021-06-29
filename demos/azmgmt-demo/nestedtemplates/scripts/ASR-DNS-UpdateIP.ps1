<# 
    .DESCRIPTION 
        This script updates the DNS of virtual machine being failed over  
         
        Pre-requisites 
        1. When you create a new Automation Account, make sure you have chosen to create a run-as account with it. 
        2. If you create a run as account on your own, give the Connection Name in the variable - $connectionName 
        3. Do a test failover of DNS virtual machine in the test network
         

        What all you need to change in this script? 
        1. Change the value of $Location in the runbook, with the region where the Azure VMs will be running
        2. Change the value of TestDNSVMName with the name of the DNS Azure virtual machine created in test network
        3. Change the value of TestDNSVMRG with the name resource group of the DNS Azure virtual machine created in test network
        4. Change the value of ProdDNSVMName with the name of the DNS Azure virtual machine in your Azure production network
        5. Change the value of ProdDNSVMRG with the name resource group of the DNS Azure virtual machine in your Azure production network
        

        How to add the script? 
        Add this script as a post action in a recovery plan group which has the virtual machines for which DNS has to be updated 
         
        Input Parameters
        Create an input parameter using the following powershell script. 
        $InputObject = @{"#VMIdAsAvailableINASRVMProperties"=@{"Zone"="#ZoneFortheVirtualMachine";"VMName"="#HostNameofTheVirtualMachine"};"#VMIdAsAvailableINASRVMProperties2"=@{"Zone"="#ZoneFortheVirtualMachine2";"VMName"="#HostNameofTheVirtualMachine2"}}
        $RPDetails = New-Object -TypeName PSObject -Property $InputObject  | ConvertTo-Json
        New-AzureRmAutomationVariable -Name "#RecoveryPlanName" -ResourceGroupName "#AutomationAccountResourceGroup" -AutomationAccountName "#AutomationAccountName" -Value $RPDetails -Encrypted $false  

        Replace all strings starting with a '#' with appropriate value

        1. VMIdAsAvailableINASRVMProperties : VM Id as shown in virtual machine properties inside Recovery services vault (https://docs.microsoft.com/en-in/azure/site-recovery/site-recovery-runbook-automation#using-complex-variable-to-store-more-information)
        2. ZoneFortheVirtualMachine : Zone of the virtual machine
        3. HostNameofTheVirtualMachine : Host name of the virtual machine. For example for a virtual machine with FQDN myvm.contoso.com HostNameofTheVirtualMachine is myvm and Zone is contoso.com. You can add more such blocks if there are more virtual machines being failed over as part of the recovery plan. 
        4. RecoveryPlanName : Name of the RecoveryPlanName where this script will be added.
        5. AutomationAccountName : Name of the Automation Account where this script is stored.
        6. AutomationAccountResourceGroup : Name of the Resource Group of Automation Account where this script is stored.

 
    .NOTES 
        AUTHOR: Prateek.Sharma@microsoft.com 
        LASTEDIT: 20 April, 2017 
#> 



workflow ASR-DNS-UpdateIP
{
    param ( 
        [parameter(Mandatory=$false)] 
        [Object]$RecoveryPlanContext 
    ) 
 
    $connectionName = "AzureRunAsConnection" 
    $scriptpath = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/asr-automation-recovery/scripts/UpdateDNS.ps1"

    $Location = ""
    $TestDNSVMName = ""
    $TestDNSVMRG = ""
    $ProdDNSVMName = ""
    $ProdDNSVMRG = ""
    
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

 
    $VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name
    $vmMap = $RecoveryPlanContext.VmMap

    if ($RecoveryPlanContext.FailoverType -ne "Test") { 
         $DNSVMRG =   $ProdDNSVMRG
         $DNSVMName =   $ProdDNSVMName   
    }
    else {
         $DNSVMRG =   $TestDNSVMRG
         $DNSVMName =   $TestDNSVMName

    }

    $RPVariable = Get-AutomationVariable -Name $RecoveryPlanContext.RecoveryPlanName

    $RPVariable = $RPVariable | convertfrom-json

    Write-Output $RPVariable

 foreach($VMID in $VMinfo) 
    { 
        
           $VM = $vmMap.$VMID
           $VMDetails = $RPVariable.$VMID
           Write-output "VMDetails:" $VMDetails
        if( !(($VM -eq $Null) -Or ($VM.ResourceGroupName -eq $Null) -Or ($VM.RoleName -eq $Null) -Or ($VMDetails -eq $Null) -Or ($VMDetails.zone -eq $Null) -Or ($VMDetails.VMName -eq $Null))) { 
            #this is when some data is not available and it will fail 
 
            InlineScript{
                $azurevm = Get-AzureRMVM -ResourceGroupName $Using:VM.ResourceGroupName -Name $Using:VM.RoleName 
                write-output "Updating DNS for" $azurevm.Id 
                $NicArmObject = Get-AzureRmResource -ResourceId $azurevm.NetworkInterfaceIDs[0] 
                $VMNetworkInterfaceObject = Get-AzureRmNetworkInterface -Name $NicArmObject.Name -ResourceGroupName $NicArmObject.ResourceGroupName
                $IPconfiguration = $VMNetworkInterfaceObject.IpConfigurations[0]
                $IP =  $IPconfiguration.PrivateIpAddress
                $zone = $Using:VMDetails.Zone
                $VMName = $Using:VMDetails.VMName

                $argument = "-Zone " + $Zone + " -name " + $VMName + " -IP " + $IP

                Write-Output "Removing older custom script extension"
                $DNSVM = Get-AzureRMVM -ResourceGroupName $Using:DNSVMRG -Name $Using:DNSVMName
                $csextension = $DNSVM.Extensions |  Where-Object {$_.VirtualMachineExtensionType -eq "CustomScriptExtension"}
                Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $Using:DNSVMRG -VMName $Using:DNSVMName -Name $csextension.Name -Force

                Write-output "Updating DNS with arguments:" $argument
                Set-AzureRmVMCustomScriptExtension -ResourceGroupName $Using:DNSVMRG -VMName $Using:DNSVMName -Location $Using:Location -FileUri $Using:scriptpath -Run UpdateDNS.ps1 -Name UpdateDNSCustomScript -Argument $argument 
                Write-output "Completed DNS Update"
            }
        }  

    }
}
