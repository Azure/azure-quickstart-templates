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
    "[$(Get-Date -format HH:mm:ss)] Failed ,retry in 10s. Please wait." | Out-File -Append $logpath
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

    $connectionString = "Data Source=.; Integrated Security=SSPI; Initial Catalog=CM_$SiteCode"
    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $sqlCommand = "INSERT INTO [Feature_EC] (FeatureID,Exposed) values (N'49E3EF35-718B-4D93-A427-E743228F4855',0)"
    $connection.Open() | Out-Null
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $command.ExecuteNonQuery() | Out-Null
}
else
{
    Add-CMManagementPoint -SiteSystemServerName $MPServerFullName -SiteCode $SiteCode -ClientConnectionType InternetAndIntranet -AllowDevice -GenerateAlert -SQLServerFqdnName $SQLServerFqdnName -SQLServerInstanceName $SQLInstanceName -DatabaseName $DBName -UserName $DName
    $connectionString = "Data Source=.\$SQLInstanceName; Integrated Security=SSPI; Initial Catalog=CM_$SiteCode"
    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $sqlCommand = "INSERT INTO [Feature_EC] (FeatureID,Exposed) values (N'49E3EF35-718B-4D93-A427-E743228F4855',0)"
    $connection.Open() | Out-Null
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $command.ExecuteNonQuery() | Out-Null
}

