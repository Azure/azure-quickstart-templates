#Requires -Version 5.0
[CmdletBinding()]   
param(
    # The subcription Id to log in to
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    # The tenant Id to that contains the MSI
    [Parameter(Mandatory=$true)]
    [string]
    $TenantId,
    # The Resource Group Name that contains the storage account to write to
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    # The Storage Account to write to
    [Parameter(Mandatory=$true)]
    [string]
    $StorageAccountName,
    # The name of the container to write a blob to
    [Parameter(Mandatory=$false)]
    [string]
    $ContainerName='msi'
)

if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue -ListAvailable)) 
{
    Write-Verbose 'Installing nuget Package Provider'
    Install-PackageProvider -Name nuget -Force
}

$modules=@('AzureRM.Profile';'AzureRM.Storage';'Azure.Storage')

foreach($module in $modules) 
{
    if (!(Get-Module -Name $module -ListAvailable) )
    {
        Write-Verbose "Installing PowerShell Module $module"
        Install-Module $module -Force
    } 
}


$retry=0
$success=$false

# Get a token for ARM

$headers=@{Metadata="true";}
$resource="https://management.azure.com/"
$postBody=@{authority="https://login.microsoftonline.com/$TenantId"; resource="$resource"}

# Retry till we can get a token, this is only needed until we can sequence extensions in VMSS

do
    {
        try
        {
           Write-Verbose "Getting Token Retry $retry"

           $reponse=Invoke-WebRequest -Uri http://localhost:50342/oauth2/token -Method POST -Body $postBody -UseBasicParsing -Headers $headers
           $result=ConvertFrom-Json -InputObject $reponse.Content
           $success=$true
        }
        catch
        {
            Write-Verbose "Exception $_ trying to login"
            $retry++
            if ($retry -lt 5)
            {
                Write-Verbose 'Sleeeping for 60 seconds...'
                Start-Sleep 60
                Write-Verbose "Retrying attempt $retry"
            }
            else
            {
                throw $_
            }
        }
    }
while(!$success)

$retry=0
$success=$false

# Retry till we can find the subcription id in context , this is needed as the permission is set after the VMSS is created because the identity is not known until the VMSS is created 

do
    {
        try
        {

           Write-Verbose "Logging in Retry $retry"
           # Subscription will be null until permission is granted
           $loginResult=Login-AzureRmAccount -AccessToken $result.access_token -AccountId  $SubscriptionId
           if ($loginResult.Context.Subscription.Id -eq $SubscriptionId)
           {
                $success=$true
           }
           else 
           {
                throw "Subscription Id $SubscriptionId not in context"
           }

        }
        catch
        {
            Write-Verbose "Exception $_ trying to login"
            $retry++
            if ($retry -lt 5)
            {
                Write-Verbose 'Sleeeping for 60 seconds ...'
                Start-Sleep 60
                Write-Verbose "Retrying attempt $retry"
            }
            else
            {
                throw $_
            }
        }
    }
while(!$success)

$ContainerName=$ContainerName.ToLowerInvariant()
$StorageAccountKey=(Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value
$StorageContext=New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
if (!(Get-AzureStorageContainer -Context $StorageContext -Name $ContainerName -ErrorAction SilentlyContinue))
{   
    New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission Blob -ErrorAction SilentlyContinue
}

$BlobName=$env:COMPUTERNAME.ToLowerInvariant()
$FileName=[System.IO.Path]::GetTempFileName()
Get-Date|Out-File $FileName  
Set-AzureStorageBlobContent -File $FileName -Container $ContainerName -Blob $BlobName -Context $StorageContext -Force