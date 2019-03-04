Param([string[]]$rolelist) 

$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
$logpath = $ProvisionToolPath+"\InstallFeaturesLog.txt"

"Current role list: $rolelist" | Out-File -Append $logpath

Import-Module ServerManager 

#rdc
Install-WindowsFeature -Name "Rdc"

#.NET 3.5 SP1 or later
Get-WindowsFeature -Name "NET-*" | Install-WindowsFeature

if($rolelist -contains "DC")
{
}
if($rolelist -contains "Site Server")
{ 
    Add-WindowsFeature Web-Basic-Auth,Web-IP-Security,Web-Url-Auth,Web-Windows-Auth,Web-ASP,Web-Asp-Net 
    Add-WindowsFeature Web-Mgmt-Console,Web-Lgcy-Mgmt-Console,Web-Lgcy-Scripting,Web-WMI,Web-Mgmt-Service,Web-Mgmt-Tools,Web-Scripting-Tools 
}
if($rolelist -contains "Application Catalog website point")
{
    #IIS
    Add-WindowsFeature Web-Default-Doc,Web-Static-Content,Web-Windows-Auth,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
}
if($rolelist -contains "Application Catalog web service point")
{
    #IIS
    Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
}
if($rolelist -contains "Asset Intelligence synchronization point")
{
    #installed .net 4.5 or later
}
if($rolelist -contains "Certificate registration point")
{
    #IIS
    Add-WindowsFeature Web-Asp-Net,Web-Asp-Net45,Web-Metabase,Web-WMI
}
if($rolelist -contains "Distribution point")
{
    #IIS 
    Add-WindowsFeature Web-Windows-Auth,web-ISAPI-Ext
    Add-WindowsFeature Web-WMI,Web-Metabase
}
    
if($rolelist -contains "Endpoint Protection point")
{
    #.NET 3.5 SP1 is intalled
}
    
if($rolelist -contains "Enrollment point")
{
    #iis
    Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
}
if($rolelist -contains "Enrollment proxy point")
{
    #iis
    Add-WindowsFeature Web-Default-Doc,Web-Static-Content,Web-Windows-Auth,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
}
if($rolelist -contains "Fallback status point")
{
    Add-WindowsFeature Web-Metabase
}
if($rolelist -contains "Management point")
{
    #BITS
    Add-WindowsFeature BITS,BITS-IIS-Ext
    #IIS 
    Add-WindowsFeature Web-Windows-Auth,web-ISAPI-Ext
    Add-WindowsFeature Web-WMI,Web-Metabase
}
if($rolelist -contains "Reporting services point")
{
    #installed .net 4.5 or later   
}
if($rolelist -contains "Service connection point")
{
    #installed .net 4.5 or later
}
if($rolelist -contains "Software update point")
{
    #default iis configuration
    add-windowsfeature web-server 
}
if($rolelist -contains "State migration point")
{
    #iis
    Add-WindowsFeature Web-Default-Doc,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-Metabase
}