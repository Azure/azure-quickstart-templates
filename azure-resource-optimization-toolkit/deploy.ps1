<#
.SYNOPSIS  
 Deployment script for ARO Toolkit ARM Template Deployment Execution
.DESCRIPTION  
 Deployment script for ARO Toolkit ARM Template Deployment Execution
.EXAMPLE  
.\deploy.ps1 -SubscriptionId "" -ResourceGroupName "" -AzureLoginPassword "" -localAdminPassword ""
Version History  
v1.0   - Initial Release  
#>
Param(
    [String]$SubscriptionId,
    [String]$AutomationAccountName,
    [String]$ResourceGroupName,
    [String]$AzureLoginUserName,
    [String]$AzureLoginPassword
)

#*************************ENTRY POINT**********************************************

#----------------------------------------------------------------------------------
#--------------------------CREATE THE LOG FILE-------------------------------------
#----------------------------------------------------------------------------------
try
{
    $formatedDate = (Get-Date).ToString('MMddyyyy-hhmmss')
    $outfile = ".\ARO-toolkit\Logs\AROToolKit-$formatedDate.log"
    if(!(Test-Path $outfile -Type Leaf))
    {
        New-Item -Path ".\ARO-toolkit\Logs" -ItemType directory -ErrorAction SilentlyContinue
        Remove-Item -Path ".\ARO-toolkit\Logs" -Include *.log -Recurse
	    New-Item -Path "$outfile" -ItemType file -ErrorAction SilentlyContinue
    }

    $((Get-Date).ToString() + " Deployment Script: Execution Started!!!") | Out-File $outfile -Append

    Write-Output "Logging into Azure Subscription..." | Out-File $outfile -Append
    
    #-----L O G I N - A U T H E N T I C A T I O N-----
    $secPassword = ConvertTo-SecureString $AzureLoginPassword -AsPlainText -Force
    $AzureOrgIdCredential = New-Object System.Management.Automation.PSCredential($AzureLoginUserName, $secPassword)
    Login-AzureRmAccount -Credential $AzureOrgIdCredential
    Get-AzureRmSubscription -SubscriptionId $SubscriptionId | Select-AzureRmSubscription
    Write-Output "Successfully logged into Azure Subscription..." | Out-File $outfile -Append

    #Variables
    $depName ="AROToolkit"
    $newGUID = [Guid]::NewGuid() 
    $resourceGroupLocation = 'East US 2'
    $templateFilePath = ".\ARO-toolkit\azuredeploy.json"
    $parametersFilePath = ".\ARO-toolkit\azuredeploy.parameters.json"


    # Create requested resource group
    $exists = Get-AzureRmResourceGroup -Location $resourceGroupLocation | Where-Object {$_.ResourceGroupName -eq $ResourceGroupName}
    if (!$exists) {
        Write-Output "Creating resource group '$ResourceGroupName' in location '$resourceGroupLocation'" | Out-File $outfile -Append
        New-AzureRMResourceGroup -Name $ResourceGroupName -Location $resourceGroupLocation -Force
    }else {
        Write-Output "Using existing resource group '$ResourceGroupName'" | Out-File $outfile -Append
    }

    Start-Sleep 10

    Write-Output "Updating the JSON parameter file with dynamic values..."  | Out-File $outfile -Append
        
    #**********Find and Replace logic for Key vaults******************
    [string]$str=""
    ForEach($line in  Get-Content -Path $parametersFilePath)
    {
        #*****For VSO Variales
        if ($line -match "__newGuid__")
        {
            $line = $line -replace "__newGuid__", $newGUID
        }

        if ($line -match "__AutomationAccountName__")
        {
            $line = $line -replace "__AutomationAccountName__", $AutomationAccountName.Trim()
        }

        if ($line -match "__azureAdminPwd__")
        {
            $line = $line -replace "__azureAdminPwd__", $AzureLoginPassword.Trim()
        }

        if($line -match "__azureAdmin__")
        {
            $line = $line -replace "__azureAdmin__",$AzureLoginUserName.Trim()
        }            

        $str=$str+$line
    }

    Set-Content -Path $parametersFilePath -Value $str

    #Splatting parameters
    $splat = @{'Name'=$depName;
            'ResourceGroupName'=$ResourceGroupName;
            'TemplateFile'=$templateFilePath;
            'TemplateParameterFile'= $parametersFilePath
              }

    Write-Output "Starting Deployment..." | Out-File $outfile -Append
    New-AzureRmResourceGroupDeployment @splat -verbose

    $((Get-Date).ToString() + " Deployment Script: Execution Completed!!! ") | Out-File -FilePath $outfile -Append 
}
catch
{
Write-Output "Error Occurred..." | Out-File $outfile -Append
Write-Output $_.Exception | Out-File $outfile -Append

}