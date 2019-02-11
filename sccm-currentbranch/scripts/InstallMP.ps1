Param($PSSiteCode,$MPServerName,$DomainFullName,$SQLServerName,$SQLInstanceName,$DomainAdminName,$Password)

$DBName = "CM_"+$PSSiteCode

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\InstallMPLog.txt"
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

$MPServerFullName = $MPServerName + "." + $DomainFullName

if($(Get-CMSiteSystemServer -SiteSystemServerName $MPServerFullName) -eq $null)
{
    New-CMSiteSystemServer -Servername $MPServerFullName -Sitecode $SiteCode
}
$DomainName = $DomainFullName.split('.')[0]
$DName = $DomainName + "\" + $DomainAdminName

$pwd = $Password | ConvertTo-SecureString -AsPlainText -Force
while($(Get-CMAccount -UserName $DName) -eq $null)
{
    "[$(Get-Date -format HH:mm:ss)] New CM Account $DomainAdminName." | Out-File -Append $logpath
    New-CMAccount -UserName $DName -Password $pwd
    Start-Sleep -Seconds 10
}
$SQLServerFqdnName = "$SQLServerName.$env:userdnsdomain"
if($SQLInstanceName -eq "MSSQLSERVER")
{
    Add-CMManagementPoint -SiteSystemServerName $MPServerFullName -SiteCode $SiteCode -ClientConnectionType InternetAndIntranet -AllowDevice -GenerateAlert -SQLServerFqdnName $SQLServerFqdnName -DatabaseName $DBName -UserName $DName
}
else
{
    Add-CMManagementPoint -SiteSystemServerName $MPServerFullName -SiteCode $SiteCode -ClientConnectionType InternetAndIntranet -AllowDevice -GenerateAlert -SQLServerFqdnName $SQLServerFqdnName -SQLServerInstanceName $SQLInstanceName -DatabaseName $DBName -UserName $DName
}