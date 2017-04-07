<# 
    .DESCRIPTION 
        This script fails over SQL Always On Availability Group inside an Azure virtual machine  
         
        Pre-requisites 
        1. When you create a new Automation Account, make sure you have chosen to create a run-as account with it. 
        2. If you create a run as account on your own, give the Connection Name in the variable - $connectionName 
        3. Setup Azure Backup on the SQL Always On Azure virtual machine
        4. Before doing a test failover, restore a copy of the SQL Always On Azure virtual machine in the test network
         

        What all you need to change in this script? 
        1. Change the value of $Locaton with the region where SQl Always On Azure virtual machine is running 

        How to add the script? 
        Add this script as a pre action of the first group of the recovery plan 
         
        Input Parameters
        Create an input parameter using the following powershell script. 
        $InputObject = @{"TestSQLVMName" = "#TestSQLVMName" ; "TestSQLVMRG" = "#TestSQLVMRG" ; "ProdSQLVMName" = "#ProdSQLVMName" ; "ProdSQLVMRG" = "#ProdSQLVMRG"; "Paths" = @{"1"="#sqlserver:\sql\sqlazureVM\default\availabilitygroups\ag1";"2"="#sqlserver:\sql\sqlazureVM\default\availabilitygroups\ag2"}}
        $RPDetails = New-Object -TypeName PSObject -Property $InputObject  | ConvertTo-Json
        New-AzureRmAutomationVariable -Name "#RecoveryPlanName" -ResourceGroupName "#AutomationAccountResourceGroup" -AutomationAccountName "#AutomationAccountName" -Value $RPDetails -Encrypted $false  

        Replace all strings starting with a '#' with appropriate value

        1. TestSQLVMName : Name of the Azure virtual machine where you will restore SQL Always On Azure virtual machine using Azure Backup.
        2. TestSQLVMRG : Name of Resource Group of the Azure virtual machine where you will restore SQL Always On Azure virtual machine using Azure Backup.
        3. ProdSQLVMName : Name of the SQL Always On Azure virtual machine. 
        4. ProdSQLVMRG : Name of Resource Group of the SQL Always On Azure virtual machine.
        5. Paths : Fully qualified paths of the availability groups. You can add more such blocks if there are more availability groups to be failed over. This example shows two availability groups.  
        6. RecoveryPlanName : Name of the RecoveryPlanName where this script will be added.
        7. AutomationAccountName : Name of the Automation Account where this script is stored.
        8. AutomationAccountResourceGroup : Name of the Resource Group of Automation Account where this script is stored.

 
    .NOTES 
        AUTHOR: Prateek.Sharma@microsoft.com 
        LASTEDIT: 27 March, 2017 
#> 




workflow ASR-SQL-FailoverAG
{
    param ( 
        [parameter(Mandatory=$false)] 
        [Object]$RecoveryPlanContext 
    ) 
 
    $connectionName = "AzureRunAsConnection" 
    $scriptpath = "https://asrautomation.blob.core.windows.net/scripts/SQLAGFailover.ps1"
    $Location = "Southeast Asia"
    
    
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


    $RPVariable = Get-AutomationVariable -Name $RecoveryPlanContext.RecoveryPlanName
    $RPVariable = $RPVariable | convertfrom-json

    Write-Output $RPVariable

    if ($RecoveryPlanContext.FailoverType -ne "Test") { 
         $SQLVMRG =   $RPVariable.ProdSQLVMRG
         $SQLVMName =   $RPVariable.ProdSQLVMName   
    }
    else {
         $SQLVMRG =   $RPVariable.TestSQLVMRG
         $SQLVMName =   $RPVariable.TestSQLVMName
    }

    
    $PathSqno = $RPVariable.Paths | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name 
    $PathDetails = $RPVariable.Paths


 foreach($sqno in $PathSqno) 
    { 


      If(!(($sqno -eq "PSComputerName") -Or ($sqno -eq "PSShowComputerName") -Or ($sqno -eq "PSSourceJobInstanceId")))
      {  
  
           $AGPath = $PathDetails.$sqno
        if(!($AGPath -eq $Null)){  
            #this is when some data is not available and it will fail 
 
            InlineScript{

                Write-Output "Removing older custom script extension"
                $SQLVM = Get-AzureRMVM -ResourceGroupName $Using:SQLVMRG -Name $Using:SQLVMName
                $csextension = $SQLVM.Extensions |  Where-Object {$_.VirtualMachineExtensionType -eq "CustomScriptExtension"}
                Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $Using:SQLVMRG -VMName $Using:SQLVMName -Name $csextension.Name -Force

                $argument = "-Path " + $Using:AGPath

                Write-output "Failing over:" $argument
                Set-AzureRmVMCustomScriptExtension -ResourceGroupName $Using:SQLVMRG -VMName $Using:SQLVMName -Location $Using:Location -FileUri $Using:scriptpath -Run SQLAGFailover.ps1 -Name SQLAGCustomscript -Argument $argument 
                Write-output "Completed AG Failover"
            }
        }  
      }
    }
}
