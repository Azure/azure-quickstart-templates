<#
.SYNOPSIS  
 Bootstrap master script for pre-configuring Automation Account
.DESCRIPTION  
 Bootstrap master script for pre-configuring Automation Account
.EXAMPLE  
.\Bootstrap_Main.ps1 
Version History  
v1.0   - Initial Release  
#>

function ValidateKeyVaultAndCreate([string] $keyVaultName, [string] $resourceGroup, [string] $KeyVaultLocation) 
{
   $GetKeyVault=Get-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue
   if (!$GetKeyVault)
   {
     Write-Warning -Message "Key Vault $keyVaultName not found. Creating the Key Vault $keyVaultName"
     $keyValut=New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $keyVaultLocation
     if (!$keyValut) {
       Write-Error -Message "Key Vault $keyVaultName creation failed. Please fix and continue"
       return
     }
     $uri = New-Object System.Uri($keyValut.VaultUri, $true)
     $hostName = $uri.Host
     Start-Sleep -s 15     
     # Note: This script will not delete the KeyVault created. If required, please delete the same manually.
   }
 }

 function CreateSelfSignedCertificate([string] $keyVaultName, [string] $certificateName, [string] $selfSignedCertPlainPassword,[string] $certPath, [string] $certPathCer, [string] $noOfMonthsUntilExpired ) 
{
   $certSubjectName="cn="+$certificateName

   $Policy = New-AzureKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" -SubjectName $certSubjectName  -IssuerName "Self" -ValidityInMonths $noOfMonthsUntilExpired -ReuseKeyOnRenewal
   $AddAzureKeyVaultCertificateStatus = Add-AzureKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName -CertificatePolicy $Policy 
  
   While($AddAzureKeyVaultCertificateStatus.Status -eq "inProgress")
   {
     Start-Sleep -s 10
     $AddAzureKeyVaultCertificateStatus = Get-AzureKeyVaultCertificateOperation -VaultName $keyVaultName -Name $certificateName
   }
 
   if($AddAzureKeyVaultCertificateStatus.Status -ne "completed")
   {
     Write-Error -Message "Key vault cert creation is not sucessfull and its status is: $status.Status" 
   }

   $secretRetrieved = Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $certificateName
   $pfxBytes = [System.Convert]::FromBase64String($secretRetrieved.SecretValueText)
   $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
   $certCollection.Import($pfxBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
   
   #Export  the .pfx file 
   $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $selfSignedCertPlainPassword)
   [System.IO.File]::WriteAllBytes($certPath, $protectedCertificateBytes)

   #Export the .cer file 
   $cert = Get-AzureKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName
   $certBytes = $cert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
   [System.IO.File]::WriteAllBytes($certPathCer, $certBytes)

   # Delete the cert after downloading
   $RemoveAzureKeyVaultCertificateStatus = Remove-AzureKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName -PassThru -Force -ErrorAction SilentlyContinue -Confirm:$false
 }

 function CreateServicePrincipal([System.Security.Cryptography.X509Certificates.X509Certificate2] $PfxCert, [string] $applicationDisplayName) {  
   $CurrentDate = Get-Date
   $keyValue = [System.Convert]::ToBase64String($PfxCert.GetRawCertData())
   $KeyId = [Guid]::NewGuid() 

   $KeyCredential = New-Object  Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential
   $KeyCredential.StartDate = $CurrentDate
   $KeyCredential.EndDate= [DateTime]$PfxCert.GetExpirationDateString()
   $KeyCredential.KeyId = $KeyId
   $KeyCredential.CertValue  = $keyValue

   # Use Key credentials and create AAD Application
   $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $applicationDisplayName) -IdentifierUris ("http://" + $KeyId) -KeyCredentials $KeyCredential

   $ServicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
   $GetServicePrincipal = Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id

   # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
   Start-Sleep -s 15

   $NewRole = $null
   $Retries = 0;
   While ($NewRole -eq $null -and $Retries -le 6)
   {
      New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
      Start-Sleep -s 10
      $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
      $Retries++;
   }

   return $Application.ApplicationId.ToString();
 }

 function CreateAutomationCertificateAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $certifcateAssetName,[string] $certPath, [string] $certPlainPassword, [Boolean] $Exportable) {
   $CertPassword = ConvertTo-SecureString $certPlainPassword -AsPlainText -Force   
   Remove-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup -automationAccountName $automationAccountName -Name $certifcateAssetName -ErrorAction SilentlyContinue
   New-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup -automationAccountName $automationAccountName -Path $certPath -Name $certifcateAssetName -Password $CertPassword -Exportable:$Exportable  | write-verbose
 }

 function CreateAutomationConnectionAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $connectionAssetName, [string] $connectionTypeName, [System.Collections.Hashtable] $connectionFieldValues ) {
   Remove-AzureRmAutomationConnection -ResourceGroupName $resourceGroup -automationAccountName $automationAccountName -Name $connectionAssetName -Force -ErrorAction SilentlyContinue
   New-AzureRmAutomationConnection -ResourceGroupName $ResourceGroup -automationAccountName $automationAccountName -Name $connectionAssetName -ConnectionTypeName $connectionTypeName -ConnectionFieldValues $connectionFieldValues 
 }


try
{
    Write-Output "Bootstrap main script execution started..."

    Write-Output "Checking for the RunAs account..."

    $servicePrincipalConnection=Get-AutomationConnection -Name 'AzureRunAsConnection' -ErrorAction SilentlyContinue

    #---------Inputs variables for NewRunAsAccountCertKeyVault.ps1 child bootstrap script--------------
    $automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
    $SubscriptionId = Get-AutomationVariable -Name 'Internal_AzureSubscriptionId'
    $aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

    if ($servicePrincipalConnection -eq $null)
    {
        #---------Read the Credentials variable---------------
        $myCredential = Get-AutomationPSCredential -Name 'AzureCredentials'  
        $AzureLoginUserName = $myCredential.UserName
        $securePassword = $myCredential.Password
        $AzureLoginPassword = $myCredential.GetNetworkCredential().Password
    
        #++++++++++++++++++++++++STEP 1 execution starts++++++++++++++++++++++++++
    
        #In Step 1 we are creating keyvault to generate cert and creating runas account...

        Write-Output "Executing Step-1 : Create the keyvault certificate and connection asset..."
    
        Write-Output "RunAsAccount Creation Started..."

        try
         {
            Write-Output "Logging into Azure Subscription..."
    
            #-----L O G I N - A U T H E N T I C A T I O N-----
            $secPassword = ConvertTo-SecureString $AzureLoginPassword -AsPlainText -Force
            $AzureOrgIdCredential = New-Object System.Management.Automation.PSCredential($AzureLoginUserName, $secPassword)
            Login-AzureRmAccount -Credential $AzureOrgIdCredential
            Get-AzureRmSubscription -SubscriptionId $SubscriptionId | Select-AzureRmSubscription
            Write-Output "Successfully logged into Azure Subscription..."

            $AzureRMProfileVersion= (Get-Module AzureRM.Profile).Version
            if (!(($AzureRMProfileVersion.Major -ge 2 -and $AzureRMProfileVersion.Minor -ge 1) -or ($AzureRMProfileVersion.Major -gt 2)))
            {
                Write-Error -Message "Please install the latest Azure PowerShell and retry. Relevant doc url : https://docs.microsoft.com/en-us/powershell/azureps-cmdlets-docs/ "
                return
            }
     
            [String] $ApplicationDisplayName="$($automationAccountName)App1"
            [Boolean] $CreateClassicRunAsAccount=$false
            [String] $SelfSignedCertPlainPassword = [Guid]::NewGuid().ToString().Substring(0,8)+"!" 
            [String] $KeyVaultName="KeyVault"+ [Guid]::NewGuid().ToString().Substring(0,5)        
            [int] $NoOfMonthsUntilExpired = 36
    
            $RG = Get-AzureRmResourceGroup -Name $aroResourceGroupName 
            $KeyVaultLocation = $RG[0].Location
 
            # Create Run As Account using Service Principal
            $CertifcateAssetName = "AzureRunAsCertificate"
            $ConnectionAssetName = "AzureRunAsConnection"
            $ConnectionTypeName = "AzureServicePrincipal"
 
            Write-Output "Creating Keyvault for generating cert..."
            ValidateKeyVaultAndCreate $KeyVaultName $aroResourceGroupName $KeyVaultLocation

            $CertificateName = $automationAccountName+$CertifcateAssetName
            $PfxCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".pfx")
            $PfxCertPlainPasswordForRunAsAccount = $SelfSignedCertPlainPassword
            $CerCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".cer")

            Write-Output "Generating the cert using Keyvault..."
            CreateSelfSignedCertificate $KeyVaultName $CertificateName $PfxCertPlainPasswordForRunAsAccount $PfxCertPathForRunAsAccount $CerCertPathForRunAsAccount $NoOfMonthsUntilExpired


            Write-Output "Creating service principal..."
            # Create Service Principal
            $PfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($PfxCertPathForRunAsAccount, $PfxCertPlainPasswordForRunAsAccount)
            $ApplicationId=CreateServicePrincipal $PfxCert $ApplicationDisplayName

            Write-Output "Creating Certificate in the Asset..."
            # Create the automation certificate asset
            CreateAutomationCertificateAsset $aroResourceGroupName $automationAccountName $CertifcateAssetName $PfxCertPathForRunAsAccount $PfxCertPlainPasswordForRunAsAccount $true

            # Populate the ConnectionFieldValues
            $SubscriptionInfo = Get-AzureRmSubscription -SubscriptionId $SubscriptionId
            $TenantID = $SubscriptionInfo | Select-Object TenantId -First 1
            $Thumbprint = $PfxCert.Thumbprint
            $ConnectionFieldValues = @{"ApplicationId" = $ApplicationId; "TenantId" = $TenantID.TenantId; "CertificateThumbprint" = $Thumbprint; "SubscriptionId" = $SubscriptionId} 

            Write-Output "Creating Connection in the Asset..."
            # Create a Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
            CreateAutomationConnectionAsset $aroResourceGroupName $automationAccountName $ConnectionAssetName $ConnectionTypeName $ConnectionFieldValues

            Write-Output "RunAsAccount Creation Completed..."

            Write-Output "Completed Step-1 ..."
     
         }
         catch
         {
            Write-Output "Error Occurred on Step-1..."   
            Write-Output $_.Exception
            Write-Error $_.Exception
            exit
         }
    }
    else
    {
        Write-Output "RunAs account already available..."
        $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

            "Logging in to Azure..."
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        }
        catch 
        {
            if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } else{
                Write-Error -Message $_.Exception
                throw $_.Exception
                exit
            }
        }
    }
    #++++++++++++++++++++++++STEP 1 execution ends++++++++++++++++++++++++++

    #=======================STEP 2 execution starts===========================

    #In Step 2 we are creating webhook for StopAzureRmVM runbook...
    try
    {
        #---------Inputs variables for Webhook creation--------------
        $runbookNameforStopVM = "AutoSnooze_StopVM_Child"
        $webhookNameforStopVM = "AutoSnooze_StopVM_ChildWebhook"
        [String] $WebhookUriVariableName ="Internal_AutoSnooze_WebhookUri"

        $checkWebhook = Get-AzureRmAutomationWebhook -Name $webhookNameforStopVM -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue

        if($checkWebhook -eq $null)
        {
            Write-Output "Executing Step-2 : Create the webhook for $($runbookNameforStopVM)..."

            $ExpiryTime = (Get-Date).AddDays(730)

            Write-Output "Creating the Webhook ($($webhookNameforStopVM)) for the Runbook ($($runbookNameforStopVM))..."
            $Webhookdata = New-AzureRmAutomationWebhook -Name $webhookNameforStopVM -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -RunbookName $runbookNameforStopVM -IsEnabled $true -ExpiryTime $ExpiryTime -Force
            Write-Output "Successfully created the Webhook ($($webhookNameforStopVM)) for the Runbook ($($runbookNameforStopVM))..."
    
            $ServiceUri = $Webhookdata.WebhookURI

            Write-Output "Webhook Uri [$($ServiceUri)]"

            Write-Output "Creating the Assest Variable ($($WebhookUriVariableName)) in the Automation Account ($($automationAccountName)) to store the Webhook URI..."
            New-AzureRmAutomationVariable -automationAccountName $automationAccountName -Name $WebhookUriVariableName -Encrypted $False -Value $ServiceUri -ResourceGroupName $aroResourceGroupName
            Write-Output "Successfully created the Assest Variable ($($WebhookUriVariableName)) in the Automation Account ($($automationAccountName)) and Webhook URI value updated..."

            Write-Output "Webhook Creation completed..."

            Write-Output "Completed Step-2..."
        }
        else
        {
            Write-Output "Webhook already available. Ignoring Step-2..."
        }
       
    }
    catch
    {
        Write-Output "Error Occurred in Step-2..."   
        Write-Output $_.Exception
        Write-Error $_.Exception
        exit
    }    

    #=======================STEP 2 execution ends=============================

    #***********************STEP 3 execution starts**********************************

    #In Step 3 we are creating schedules for AutoSnooze and disable it...
    try
    {
        #---------Inputs variables for CreateScheduleforAlert.ps1 child bootstrap script--------------
        $runbookNameforCreateAlert = "AutoSnooze_CreateAlert_Parent"
        $scheduleNameforCreateAlert = "Schedule_AutoSnooze_CreateAlert_Parent"

        $checkMegaSchedule = Get-AzureRmAutomationSchedule -Name $scheduleNameforCreateAlert -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue

        if($checkMegaSchedule -eq $null)
        {
            Write-Output "Executing Step-3 : Create schedule for AutoSnooze_CreateAlert_Parent runbook ..."    

            #-----Configure the Start & End Time----
            $StartTime = (Get-Date).AddMinutes(10)
            $EndTime = $StartTime.AddYears(3)

            #----Set the schedule to run every 8 hours---
            $Hours = 8

            #---Create the schedule at the Automation Account level--- 
            Write-Output "Creating the Schedule ($($scheduleNameforCreateAlert)) in Automation Account ($($automationAccountName))..."
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforCreateAlert -ResourceGroupName $aroResourceGroupName -StartTime $StartTime -ExpiryTime $EndTime -HourInterval $Hours

            #Disable the schedule    
            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforCreateAlert -ResourceGroupName $aroResourceGroupName -IsEnabled $false
    
            Write-Output "Successfully created the Schedule ($($scheduleNameforCreateAlert)) in Automation Account ($($automationAccountName))..."

            $paramsAutoSnooze = @{"WhatIf"=$false}

            #---Link the schedule to the runbook--- 
            Write-Output "Registering the Schedule ($($scheduleNameforCreateAlert)) in the Runbook ($($runbookNameforCreateAlert))..."
            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforCreateAlert -ScheduleName $scheduleNameforCreateAlert -ResourceGroupName $aroResourceGroupName -Parameters $paramsAutoSnooze
            Write-Output "Successfully Registered the Schedule ($($scheduleNameforCreateAlert)) in the Runbook ($($runbookNameforCreateAlert))..."
    
            Write-Output "Completed Step-3 ..."
        }
        else
        {
            Write-Output "Schedule $($scheduleNameforCreateAlert) already available. Ignoring Step-3..."
        }
    }
    catch
    {
        Write-Output "Error Occurred in Step-3..."   
        Write-Output $_.Exception
        Write-Error $_.Exception
        exit
    }

    #***********************STEP 3 execution ends**********************************

    #-------------------STEP 4 (Bootstrap_CreateScheduleForARMVMOptimizationWrapper) execution starts---------------------

    #In Step 4 we are creating schedules for ScheduleSnooze and disable it...
    try
    {

        $runbookNameforARMVMOptimization = "ScheduledSnooze_Parent"
        $scheduleStart = "ScheduledSnooze-StartVM"
        $scheduleStop = "ScheduledSnooze-StopVM"
    
        $checkSchSnoozeStart = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStart -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue
        $checkSchSnoozeStop = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStop -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue 

        #Starts everyday 6AM
        $StartVmUTCTime = (Get-Date "13:00:00").AddDays(1).ToUniversalTime()
        #Stops everyday 6PM
        $StopVmUTCTime = (Get-Date "01:00:00").AddDays(1).ToUniversalTime()

        if($checkSchSnoozeStart -eq $null)
        {
            Write-Output "Executing Step-4 : Create schedule for ScheduledSnooze_Parent runbook ..."

            #---Create the schedule at the Automation Account level--- 
            Write-Output "Creating the Schedule in Automation Account ($($automationAccountName))..."
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStart -ResourceGroupName $aroResourceGroupName -StartTime $StartVmUTCTime -ExpiryTime $StartVmUTCTime.AddYears(1) -DayInterval 1

            Write-Output "Successfully created the Schedule in Automation Account ($($automationAccountName))..."

            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStart -ResourceGroupName $aroResourceGroupName -IsEnabled $false

            $paramsStartVM = @{"Action"="Start";"WhatIf"=$false}
            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforARMVMOptimization -ScheduleName $scheduleStart -ResourceGroupName $aroResourceGroupName -Parameters $paramsStartVM

            Write-Output "Successfully Registered the Schedule in the Runbook ($($runbookNameforARMVMOptimization))..."
        }

        if($checkSchSnoozeStop -eq $null)
        {
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStop -ResourceGroupName $aroResourceGroupName -StartTime $StopVmUTCTime -ExpiryTime $StopVmUTCTime.AddYears(1) -DayInterval 1 
            Write-Output "Successfully created the Schedule in Automation Account ($($automationAccountName))..."
               
            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStop -ResourceGroupName $aroResourceGroupName -IsEnabled $false

            Write-Output "Registering the Schedule in the Runbook ($($runbookNameforARMVMOptimization))..."

            $paramsStopVM = @{"Action"="Stop";"WhatIf"=$false}

            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforARMVMOptimization -ScheduleName $scheduleStop -ResourceGroupName $aroResourceGroupName -Parameters $paramsStopVM
    
            Write-Output "Successfully Registered the Schedule in the Runbook ($($runbookNameforARMVMOptimization))..."
         }
         
         if($checkSchSnoozeStart -ne $null -and $checkSchSnoozeStop -ne $null)
         {
            Write-Output "Schedule already available. Ignoring Step-4..."   
         }
        Write-Output "Completed Step-4 ..."
    }
    catch
    {
        Write-Output "Error Occurred in Step-4..."        
        Write-Output $_.Exception
        Write-Error $_.Exception
        exit
    }

    #-------------------STEP 4 (Bootstrap_CreateScheduleForARMVMOptimizationWrapper) execution ends---------------------

    #*******************STEP 5 execution starts********************************************

    #In Step 5 we are Creating schedules for ARO Toolkit Autoupdate functionality...
    try
    {

        $runbookNameforAutoupdate = "AROToolkit_AutoUpdate"
        $scheduleNameforAutoupdate = "Schedule_AROToolkit_AutoUpdate"
        $StartUTCTime = (Get-Date "13:00:00").AddDays(1).ToUniversalTime()

        $checkScheduleAU = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforAutoupdate -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue

        if($checkScheduleAU -eq $null)
        {

            Write-Output "Executing Step-5 : Create schedule for AROToolkit_AutoUpdate runbook ..."    
                        
            Write-Output "Creating the Schedule ($($scheduleNameforAutoupdate)) in Automation Account ($($automationAccountName))..."
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforAutoupdate -ResourceGroupName $aroResourceGroupName -StartTime $StartUTCTime -WeekInterval 2

            #Disable the schedule    
            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforAutoupdate -ResourceGroupName $aroResourceGroupName -IsEnabled $false
    
            Write-Output "Successfully created the Schedule ($($scheduleNameforAutoupdate)) in Automation Account ($($automationAccountName))..."

            #---Link the schedule to the runbook--- 
            Write-Output "Registering the Schedule ($($scheduleNameforAutoupdate)) in the Runbook ($($runbookNameforAutoupdate))..."
            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforAutoupdate -ScheduleName $scheduleNameforAutoupdate -ResourceGroupName $aroResourceGroupName
            Write-Output "Successfully Registered the Schedule ($($scheduleNameforAutoupdate)) in the Runbook ($($runbookNameforAutoupdate))..."
    
        }
        else
        {
            Write-Output "Schedule already available. Ignoring Step-5"
        }
        Write-Output "Completed Step-5 ..."
    }
    catch
    {
        Write-Output "Error Occurred in Step-5..."   
        Write-Output $_.Exception
        Write-Error $_.Exception
        exit
    }
    #*******************STEP 5 execution ends********************************************

    #~~~~~~~~~~~~~~~~~~~~STEP 6 execution starts~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #In Step 6 we are creating schedules for SequencedSnooze and disable it...

    try
    {

        $runbookNameforARMVMOptimization = "SequencedSnooze_Parent"
        $sequenceStart = "SequencedSnooze-StartVM"
        $sequenceStop = "SequencedSnooze-StopVM"

        $checkSeqSnoozeStart = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStart -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue
        $checkSeqSnoozeStop = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStop -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue 

        #Starts every monday 6AM
        $StartVmUTCTime = (Get-Date "13:00:00").AddDays(1).ToUniversalTime()
        #Stops every friday 6PM
        $StopVmUTCTime = (Get-Date "01:00:00").AddDays(1).ToUniversalTime()

        if($checkSeqSnoozeStart -eq $null)
        {
            Write-Output "Executing Step-6 : Create schedule for SequencedSnooze_Parent runbook ..."

            #---Create the schedule at the Automation Account level--- 
            Write-Output "Creating the Schedule in Automation Account ($($automationAccountName))..."
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStart -ResourceGroupName $aroResourceGroupName -StartTime $StartVmUTCTime -DaysOfWeek Monday -WeekInterval 1

            Write-Output "Successfully created the Schedule in Automation Account ($($automationAccountName))..."

            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStart -ResourceGroupName $aroResourceGroupName -IsEnabled $false

            $paramsStartVM = @{"Action"="start";"WhatIf"=$false;"ContinueOnError"=$false}
            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforARMVMOptimization -ScheduleName $sequenceStart -ResourceGroupName $aroResourceGroupName -Parameters $paramsStartVM

            Write-Output "Successfully Registered the Schedule in the Runbook ($($runbookNameforARMVMOptimization))..."
        }

        if($checkSeqSnoozeStop -eq $null)
        {
            Write-Output "Executing Step-6 : Create schedule for SequencedSnooze_Parent runbook ..."

            #---Create the schedule at the Automation Account level--- 
            Write-Output "Creating the Schedule in Automation Account ($($automationAccountName))..."
            New-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStop -ResourceGroupName $aroResourceGroupName -StartTime $StopVmUTCTime -DaysOfWeek Friday -WeekInterval 1

            Write-Output "Successfully created the Schedule in Automation Account ($($automationAccountName))..."

            Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequenceStop -ResourceGroupName $aroResourceGroupName -IsEnabled $false

            $paramsStartVM = @{"Action"="stop";"WhatIf"=$false;"ContinueOnError"=$false}
            Register-AzureRmAutomationScheduledRunbook -automationAccountName $automationAccountName -Name $runbookNameforARMVMOptimization -ScheduleName $sequenceStop -ResourceGroupName $aroResourceGroupName -Parameters $paramsStartVM

            Write-Output "Successfully Registered the Schedule in the Runbook ($($runbookNameforARMVMOptimization))..."
        }

        if($checkSeqSnoozeStart -ne $null -and $checkSeqSnoozeStop -ne $null)
         {
            Write-Output "Schedule already available. Ignoring Step-6..."   
         }
        Write-Output "Completed Step-6 ..."

    }
    catch
    {
        Write-Output "Error Occurred in Step-6..."        
        Write-Output $_.Exception
        Write-Error $_.Exception
        exit
    }


    #~~~~~~~~~~~~~~~~~~~~STEP 6 execution ends~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #*******************STEP 7 execution starts********************************************
    #In Step 7 we are linking the Automation Workspace to OMS Log analytics
    
    try{
        #Get AutomationAccountId for the deployed automation account
        $automationAccountId=(Find-AzureRmResource -ResourceType "Microsoft.Automation/automationAccounts" -ResourceNameContains $automationAccountName).ResourceId   
        $Status = (Get-AzureRmDiagnosticSetting -ResourceID $automationAccountId | Select-Object -ExpandProperty Logs | Where-Object {$_.Enabled -eq $false}).Count
        if ($Status -gt 0) 
        {
            Write-Output "Executing Step-7 : Linking Automation Workspace to OMS Log Analytics..."
            Write-Output "Checking if omsWorkspaceId Variable is defined..."
            $omsWorkspaceId = Get-AzureRmAutomationVariable -Name 'Internal_omsWorkspaceId' -ResourceGroupName $aroResourceGroupName -automationAccountName $automationAccountName -ErrorAction SilentlyContinue
            #Link to OMS Logging
            if ([string]::IsNullOrWhiteSpace($omsWorkspaceId.Value)) {
                Write-Output "omsWorkspaceId Variable is null, skipping OMS Log Analytics link step..."
            } else {
                Write-Output "omsWorkspaceId Variable Found!  Linking to OMS Log Analytics..."
                Set-AzureRmDiagnosticSetting -ResourceId $automationAccountId -WorkspaceId $omsWorkspaceId.Value -Enabled $true
                Start-Sleep -s 15
                $Status = (Get-AzureRmDiagnosticSetting -ResourceID $automationAccountId | Select-Object -ExpandProperty Logs | Where-Object {$_.Enabled -eq $false}).Count
                    if ($Status -eq 0) {
                        Write-Output "Successfully linked Automation account to OMS Log Analytics"
                    } else {
                        Write-Output "Failed to link Automation Account with OMS Log Analytics"
                    }
            }
        } else {
            Write-Output "OMS Logging is already enabled...."
        }
        Write-Output "Completed Step-7 ..."
    }
    catch 
    {
        Write-Output "Error Occurred in Step-7..."   
        Write-Output $_.Exception
        Write-Error $_.Exception        
    }
    
    #*******************STEP 7 execution ends**********************************************

    #*******************STEP 8 execution starts********************************************

    #In Step 8 we are deleting the bootstrap script, Credential asset variable, and Keyvault...
    try
    {

        Write-Output "Executing Step-8 : Performing clean up tasks (Bootstrap script, Bootstrap Schedule, Credential asset variable, and Keyvault) ..."

        if($KeyVaultName -ne $null)
        {
            Write-Output "Removing the Keyvault : ($($KeyVaultName))..."
            Remove-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $aroResourceGroupName -Confirm:$False -Force
        }
        
        $checkCredentials = Get-AzureRmAutomationCredential -Name "AzureCredentials" -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue
        
        if($checkCredentials -ne $null)
        {
            Write-Output "Removing the Azure Credentials..."

            Remove-AzureRmAutomationCredential -Name "AzureCredentials" -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName 
        }

        $checkScheduleBootstrap = Get-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name "startBootstrap" -ResourceGroupName $aroResourceGroupName -ErrorAction SilentlyContinue

        if($checkScheduleBootstrap -ne $null)
        {

            Write-Output "Removing Bootstrap Schedule..."    
                        
            Remove-AzureRmAutomationSchedule -Name "startBootstrap" -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Force
        }    

        Write-Output "Removing omsWorkspaceId Variable..."
        
        Remove-AzureRmAutomationVariable -Name 'Internal_omsWorkspaceId' -ResourceGroupName $aroResourceGroupName -automationAccountName $automationAccountName -ErrorAction SilentlyContinue


        Write-Output "Removing the Bootstrap_Main Runbook..."

        Remove-AzureRmAutomationRunbook -Name "Bootstrap_Main" -ResourceGroupName $aroResourceGroupName -automationAccountName $automationAccountName -Force


        Write-Output "Completed Step-8 ..."
    }
    catch
    {
        Write-Output "Error Occurred in Step-8..."   
        Write-Output $_.Exception
        Write-Error $_.Exception        
    }

    #*******************STEP 8 execution ends**********************************************

    Write-Output "Bootstrap wrapper script execution completed..."  

}
catch
{
    Write-Output "Error Occurred in Bootstrap Wrapper..."   
    Write-Output $_.Exception
    Write-Error $_.Exception
}
