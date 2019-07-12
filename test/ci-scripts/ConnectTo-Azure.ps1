<#

Use this script at the start of a pipeline to install the Az cmdlets and authenticate a machine's PowerShell sessions to Azure using the provided service principal

#>
param(
    [string][Parameter(mandatory=$true)] $appId,
    [string][Parameter(mandatory=$true)] $secret,
    [string][Parameter(mandatory=$true)] $tenantId,
    [string][Parameter(mandatory=$true)] $subscriptionId,
    [switch] $InstallAzModule
)

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery -verbose

if ($InstallAzModule){
    Install-Module -Name Az -AllowClobber -verbose
}

$pscredential = New-Object System.Management.Automation.PSCredential($appId, (ConvertTo-SecureString $secret -AsPlainText -Force))

Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId

Select-AzSubscription $subscriptionId
