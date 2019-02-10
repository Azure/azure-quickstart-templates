Param($PSSiteCode,$DPServerName,$DomainFullName)

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\InstallDPLog.txt"
$SiteCode = $PSSiteCode # Site code 

$ProviderMachineName = $env:COMPUTERNAME+"."+$DomainFullName # SMS Provider machine name

# Customizations
$initParams = @{}
if($ENV:SMS_ADMIN_UI_PATH -eq $null)
{
    $ENV:SMS_ADMIN_UI_PATH = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386"
}

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
}

# Connect to the site's drive if it is not already present
"[$(Get-Date -format HH:mm:ss)] Setting PS Drive..." | Out-File -Append $logpath
New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
while((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
{
    "[$(Get-Date -format HH:mm:ss)] Retry in 10s to set PS Drive. Please wait." | Out-File -Append $logpath
    Start-Sleep -Seconds 10
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$DPServerFullName = $DPServerName + "." + $DomainFullName
if($(Get-CMSiteSystemServer -SiteSystemServerName $DPServerFullName) -eq $null)
{
    New-CMSiteSystemServer -Servername $DPServerFullName -Sitecode $SiteCode
}

$Date = [DateTime]::Now.AddYears(10)
Add-CMDistributionPoint -SiteSystemServerName $DPServerFullName -SiteCode $SiteCode -CertificateExpirationTimeUtc $Date
