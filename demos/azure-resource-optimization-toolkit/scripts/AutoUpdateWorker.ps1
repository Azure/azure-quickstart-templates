<#
.SYNOPSIS  
 AutoUpdate worker Module for ARO Toolkit future releases
.DESCRIPTION  
 AutoUpdate worker Module for ARO Toolkit future releases
.EXAMPLE  
.\AutoUpdateWorker.ps1 
Version History  
v1.0   - <dev> - Initial Release  
#>


#-----L O G I N - A U T H E N T I C A T I O N-----
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
    }
}

try
{
    Write-Output "AutoUpdate Worker execution starts..."
    
    #Local Variables

    $GithubRootPath = "https://raw.githubusercontent.com/Microsoft/MSITARM"
    $GithubBranch = "azure-resource-optimization-toolkit"
    $ScriptPath = "azure-resource-optimization-toolkit/nestedtemplates"
    $FileName = "Automation.json"
    $GithubFullPath = "$($GithubRootPath)/$($GithubBranch)/$($ScriptPath)/$($FileName)"

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

    $WebClient = New-Object System.Net.WebClient

    Write-Output "Download the $($FileName) template from Github..."

    $WebClient.DownloadFile($($GithubFullPath),"$PSScriptRoot\$($FileName)")
    
    $jsonContent=Get-Content "$PSScriptRoot\$($FileName)"

    Write-Output "Deserialize the JSON..."
    $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $jsonData = $serializer.DeserializeObject($jsonContent)

    #Get the Automation Account tags to read the version
    Write-Output "Reading the Automation Account details..."

    $automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
    $aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

    $AutomationAccountDetails = Get-AzureRmAutomationAccount -Name $automationAccountName -ResourceGroupName $aroResourceGroupName
    $CurrentVersion = $AutomationAccountDetails.Tags.Values
    $UpdateVersion = $jsonData.variables.AROToolkitVersion

    Write-Output "Checking the ARO Toolkit version..."
    $CurrentVersionCompare = New-Object System.Version($CurrentVersion)
    $UpdateVersionCompare = New-Object System.Version($UpdateVersion)

    $VersionDiff = $UpdateVersionCompare.CompareTo($CurrentVersionCompare)

    if(  $VersionDiff -gt 0)
    {
        Write-Output "Current version is: $($CurrentVersion)"
        Write-Output "New version $($UpdatedVersion) is available and hence performing the upgrade..."
        #Prepare the Current variable object
        #---------Read all the input variables---------------
        Write-Output "======================================"
        Write-Output "Checking for asset variable updates..."
        Write-Output "======================================"
        $ExistingVariables = Get-AzureRmAutomationVariable -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName | Select-Object Name 
        $ExistingVariables = $ExistingVariables | Foreach {"$($_.Name)"} | Sort-Object Name
        $NewVariables=$jsonData.variables.Keys | Where-Object { $_.Trim() -match "Internal" -or $_ -match "External" } | Sort-Object

        $DiffVariables = Compare-Object -ReferenceObject $NewVariables -DifferenceObject $ExistingVariables | ?{$_.sideIndicator -eq "<="}| Select InputObject

        if($DiffVariables -ne $null)
        {
            Write-Output "New asset variables found and creating now..."
            Write-Output $DiffVariables
            #Create all the new variables
            $newResourceVariables = $jsonData.resources | foreach{$_.resources}
            foreach ($difv in $DiffVariables)
            {
                foreach($newvar in $newResourceVariables)
                {
                    if(($newvar.name -like "*$($difv.InputObject)*" -eq $true) -and ($newvar.type -eq "variables"))
                    {
                        [string[]] $rvarPropValArray = $newvar.properties.value.Split(",")

                        if($rvarPropValArray.get(1) -ne $null -and $rvarPropValArray.get(1).Contains('"') -ne "True")
                        {
                            [string] $rvarPropVal = $rvarPropValArray.get(1).Replace("'","")                            
                        }
                        else
                        {
                            $rvarPropVal = ""
                        }
                        New-AzureRmAutomationVariable -Name $difv.InputObject.Trim() -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Encrypted $False -Value $rvarPropVal.Trim()
                        break;
                    }
            
                }
            }
        }
        else
        {
            Write-Output "No updates needed for asset variables..."
        }
    
        Write-Output "================================="
        Write-Output "Checking for Runbooks updates..."
        Write-Output "================================="
        #Find the delta runbooks to create/update
        $runbooks=$jsonData.variables.runbooks.Values
        $Runbooktable = [ordered]@{}

        foreach($runb in $runbooks)
        {
            #ignore the bootstrap and AROToolkit_AutoUpdate runboooks
            if($runb.name -notlike "*Bootstrap*")
            {
                [string[]] $runbookScriptUri = $runb.scriptUri -split ","
                $Runbooktable.Add($runb.name,$runbookScriptUri.get(1).Replace(")]","").Replace("'",""))
                $currentRunbook = Get-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Name $runb.name -ErrorAction SilentlyContinue
                #check if this is new runbook or existing
                if($currentRunbook -ne $null)
                {
                    $currentRBversion = $currentRunbook.Tags.Values        
                    $NewVersion = $runb.version
                    $CVrbCompare = New-Object System.Version($currentRBversion)
                    $NVrbCompare = New-Object System.Version($NewVersion)
                    $VersionDiffRB = $NVrbCompare.CompareTo($CVrbCompare)

                    if($VersionDiffRB -gt 0)
                    {
                        $RunbookDownloadPath = "$($GithubRootPath)/$($GithubBranch)/azure-resource-optimization-toolkit$($Runbooktable[$runb.name])"
                        Write-Output "Updates needed for $($runb.name)..."
                        #Now download the runbook and do the update
                        Write-Output "Downloading the updated PowerShell script from Github..."
                        $WebClientRB = New-Object System.Net.WebClient
                        
                        $WebClientRB.DownloadFile($($RunbookDownloadPath),"$PSScriptRoot\$($runb.name).ps1")
                        $RunbookScriptPath = "$PSScriptRoot\$($runb.name).ps1"

                        Write-Output "Updating the Runbook content..." 
                        Import-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Path $RunbookScriptPath -Name $runb.name -Tags @{version=$NewVersion} -Force -Type PowerShell

                        Write-Output "Publishing the Runbook $($runb.name)..."
                        Publish-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Name $runb.name                
                    }
                }
                else
                {
                    $RunbookDownloadPath = "$($GithubRootPath)/$($GithubBranch)/azure-resource-optimization-toolkit$($Runbooktable[$runb.name])"
                    Write-Output "New Runbook $($runb.name) found..."
                    #New Runbook. So download and create it
                    Write-Output "Downloading the PowerShell script from Github..."
                    $WebClientRB = New-Object System.Net.WebClient
                    $WebClientRB.DownloadFile($($RunbookDownloadPath),"$PSScriptRoot\$($runb.name).ps1")
                    $RunbookScriptPath = "$PSScriptRoot\$($runb.name).ps1"
                    $NewVersion = $runb.version

                    Write-Output "Creating the Runbook in the Automation Account..." 
                    New-AzureRmAutomationRunbook -Name $runb.name -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Type PowerShell -Description "New Runbook"
                    Import-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Path $RunbookScriptPath -Name $runb.name -Force -Type PowerShell -Tags @{version=$NewVersion} 

                    Write-Output "Publishing the new Runbook $($runb.name)..."
                    Publish-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Name $runb.name
                }
            }
        }
        
        Write-Output "============================="
        Write-Output "Checking for new schedule..."
        Write-Output "============================="

        #just run the bootstrap_main runbook to create the schedules
        $Bootstrap_MainRunbook = "Bootstrap_Main"

        $RunbookDownloadPath = "$($GithubRootPath)/$($GithubBranch)/demos/azure-resource-optimization-toolkit/scripts/Bootstrap_Main.ps1"
        Write-Output "Downloading the Bootstrap_Main PowerShell script from Github..."
        $WebClientRB = New-Object System.Net.WebClient
        $WebClientRB.DownloadFile($($RunbookDownloadPath),"$PSScriptRoot\$($Bootstrap_MainRunbook).ps1")
        $RunbookScriptPath = "$PSScriptRoot\Bootstrap_Main.ps1"
        
        Write-Output "Creating the Runbook in the Automation Account..." 
        New-AzureRmAutomationRunbook -Name $Bootstrap_MainRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Type PowerShell -Description "New Runbook"
        Import-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Path $RunbookScriptPath -Name $Bootstrap_MainRunbook -Force -Type PowerShell

        Write-Output "Publishing the Bootstrap_Main Runbook..."
        Publish-AzureRmAutomationRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Name $Bootstrap_MainRunbook

        Start-AzureRmAutomationRunbook -Name $Bootstrap_MainRunbook -automationAccountName $automationAccountName -ResourceGroupName $aroResourceGroupName -Wait

        #Update the Automation Account version tag to latest version
        Set-AzureRmAutomationAccount -Name $automationAccountName -ResourceGroupName $aroResourceGroupName -Tags @{AROToolkitVersion=$UpdateVersion}

    }    
    elseif($VersionDiff -le 0)
    {
        Write-Output "You are having the latest version of ARO Toolkit and hence no update needed..."
    }

    Write-Output "AutoUpdate worker execution completed..."
}
catch
{
    Write-Output "Error Occurred in the AutoUpdate worker runbook..."
    Write-Output $_.Exception
}

