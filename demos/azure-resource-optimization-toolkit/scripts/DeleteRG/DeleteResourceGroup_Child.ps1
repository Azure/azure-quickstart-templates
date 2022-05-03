<#
.SYNOPSIS  
 Script for deleting the resource group
.DESCRIPTION  
 Script for deleting the resource group
.EXAMPLE  
.\DeleteResourceGroup_Child.ps1 
Version History  
v1.0   -Initial Release  
#>

Param(
    [String]$RGName
)
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
    if ($RGName -eq $null)
    {
        Write-Warning "$($RGName) is empty. Please Verify!"
    }
    else
    {  
        Write-Output "Removing the resource group $($RGName)..."
        Remove-AzureRmResourceGroup -Name $RGName.Trim() -Force
    }
    
}
catch
{
    Write-Output "Error Occurred..."
    Write-Output $_.Exception
}
