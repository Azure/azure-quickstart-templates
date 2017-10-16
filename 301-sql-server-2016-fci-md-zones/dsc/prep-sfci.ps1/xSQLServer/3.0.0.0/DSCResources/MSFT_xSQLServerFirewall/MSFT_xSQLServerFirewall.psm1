$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $InstanceName = $InstanceName.ToUpper()

    Import-Module $PSScriptRoot\..\..\xPDT.psm1

    $Path = Join-Path -Path (Join-Path -Path $SourcePath -ChildPath $SourceFolder) -ChildPath "setup.exe"
    $Path = ResolvePath $Path
    $SQLVersion = GetSQLVersion -Path $Path
    
    if($InstanceName -eq "MSSQLSERVER")
    {
        $DBServiceName = "MSSQLSERVER"
        $AgtServiceName = "SQLSERVERAGENT"
        $FTServiceName = "MSSQLFDLauncher"
        $RSServiceName = "ReportServer"
        $ASServiceName = "MSSQLServerOLAPService"
    }
    else
    {
        $DBServiceName = "MSSQL`$$InstanceName"
        $AgtServiceName = "SQLAgent`$$InstanceName"
        $FTServiceName = "MSSQLFDLauncher`$$InstanceName"
        $RSServiceName = "ReportServer`$$InstanceName"
        $ASServiceName = "MSOLAP`$$InstanceName"
    }
    $ISServiceName = "MsDtsServer" + $SQLVersion + "0"
    
    $Ensure = "Present"
    $Services = Get-Service
    $FeaturesInstalled = ""
    foreach($Feature in $Features.Split(","))
    {
        switch($Feature)
        {
            "SQLENGINE"
            {
                if($Services | Where-Object {$_.Name -eq $DBServiceName})
                {
                    $FeaturesInstalled += "SQLENGINE,"
                    if(Get-FirewallRule -DisplayName ("SQL Server Database Engine instance " + $InstanceName) -Application ((GetSQLPath -Feature "SQLENGINE" -InstanceName $InstanceName) + "\sqlservr.exe"))
                    {
                        $DatabaseEngineFirewall = $true
                    }
                    else
                    {
                        $DatabaseEngineFirewall = $false
                        $Ensure = "Absent"
                    }
                    if(Get-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser")
                    {
                        $BrowserFirewall = $true
                    }
                    else
                    {
                        $BrowserFirewall = $false
                        $Ensure = "Absent"
                    }
                }
            }
            "RS"
            {
                if($Services | Where-Object {$_.Name -eq $RSServiceName})
                {
                    $FeaturesInstalled += "RS,"
                    if((Get-FirewallRule -DisplayName "SQL Server Reporting Services 80" -Port "TCP/80") -and (Get-FirewallRule -DisplayName "SQL Server Reporting Services 443" -Port "TCP/443"))
                    {
                        $ReportingServicesFirewall = $true
                    }
                    else
                    {
                        $ReportingServicesFirewall = $false
                        $Ensure = "Absent"
                    }
                }
            }
            "AS"
            {
                if($Services | Where-Object {$_.Name -eq $ASServiceName})
                {
                    $FeaturesInstalled += "AS,"
                    if(Get-FirewallRule -DisplayName "SQL Server Analysis Services instance $InstanceName" -Service $ASServiceName)
                    {
                        $AnalysisServicesFirewall = $true
                    }
                    else
                    {
                        $AnalysisServicesFirewall = $false
                        $Ensure = "Absent"
                    }
                    if(Get-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser")
                    {
                        $BrowserFirewall = $true
                    }
                    else
                    {
                        $BrowserFirewall = $false
                        $Ensure = "Absent"
                    }
                }
            }
            "IS"
            {
                if($Services | Where-Object {$_.Name -eq $ISServiceName})
                {
                    $FeaturesInstalled += "IS,"
                    if((Get-FirewallRule -DisplayName "SQL Server Integration Services Application" -Application ((GetSQLPath -Feature "IS" -SQLVersion $SQLVersion) + "Binn\MsDtsSrvr.exe")) -and (Get-FirewallRule -DisplayName "SQL Server Integration Services Port" -Port "TCP/135"))
                    {
                        $IntegrationServicesFirewall = $true
                    }
                    else
                    {
                        $IntegrationServicesFirewall = $false
                        $Ensure = "Absent"
                    }
                }
            }
        }
    }
    $FeaturesInstalled = $FeaturesInstalled.Trim(",")

    $returnValue = @{
        Ensure = $Ensure
        SourcePath = $SourcePath
        SourceFolder = $SourceFolder
        Features = $FeaturesInstalled
        InstanceName = $InstanceName
        DatabaseEngineFirewall = $DatabaseEngineFirewall
        BrowserFirewall = $BrowserFirewall
        ReportingServicesFirewall = $ReportingServicesFirewall
        AnalysisServicesFirewall = $AnalysisServicesFirewall
        IntegrationServicesFirewall = $IntegrationServicesFirewall
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $InstanceName = $InstanceName.ToUpper()

    Import-Module $PSScriptRoot\..\..\xPDT.psm1

    $Path = Join-Path -Path (Join-Path -Path $SourcePath -ChildPath $SourceFolder) -ChildPath "setup.exe"
    $Path = ResolvePath $Path
    $SQLVersion = GetSQLVersion -Path $Path

    if($InstanceName -eq "MSSQLSERVER")
    {
        $DBServiceName = "MSSQLSERVER"
        $AgtServiceName = "SQLSERVERAGENT"
        $FTServiceName = "MSSQLFDLauncher"
        $RSServiceName = "ReportServer"
        $ASServiceName = "MSSQLServerOLAPService"
    }
    else
    {
        $DBServiceName = "MSSQL`$$InstanceName"
        $AgtServiceName = "SQLAgent`$$InstanceName"
        $FTServiceName = "MSSQLFDLauncher`$$InstanceName"
        $RSServiceName = "ReportServer`$$InstanceName"
        $ASServiceName = "MSOLAP`$$InstanceName"
    }
    $ISServiceName = "MsDtsServer" + $SQLVersion + "0"
    
    $SQLData = Get-TargetResource -SourcePath $SourcePath -SourceFolder $SourceFolder -Features $Features -InstanceName $InstanceName

    foreach($Feature in $SQLData.Features.Split(","))
    {
        switch($Feature)
        {
            "SQLENGINE"
            {
                if(!($SQLData.DatabaseEngineFirewall)){
                    if(!(Get-FirewallRule -DisplayName ("SQL Server Database Engine instance " + $InstanceName) -Application ((GetSQLPath -Feature "SQLENGINE" -InstanceName $InstanceName) + "\sqlservr.exe")))
                    {
                        New-FirewallRule -DisplayName ("SQL Server Database Engine instance " + $InstanceName) -Application ((GetSQLPath -Feature "SQLENGINE" -InstanceName $InstanceName) + "\sqlservr.exe")
                    }
                }
                if(!($SQLData.BrowserFirewall)){
                    if(!(Get-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser"))
                    {
                        New-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser"
                    }
                }
            }
            "RS"
            {
                if(!($SQLData.ReportingServicesFirewall)){
                    if(!(Get-FirewallRule -DisplayName "SQL Server Reporting Services 80" -Port "TCP/80"))
                    {
                        New-FirewallRule -DisplayName "SQL Server Reporting Services 80" -Port "TCP/80"
                    }
                    if(!(Get-FirewallRule -DisplayName "SQL Server Reporting Services 443" -Port "TCP/443"))
                    {
                        New-FirewallRule -DisplayName "SQL Server Reporting Services 443" -Port "TCP/443"
                    }
                }
            }
            "AS"
            {
                if(!($SQLData.AnalysisServicesFirewall)){
                    if(!(Get-FirewallRule -DisplayName "SQL Server Analysis Services instance $InstanceName" -Service $ASServiceName))
                    {
                        New-FirewallRule -DisplayName "SQL Server Analysis Services instance $InstanceName" -Service $ASServiceName
                    }
                }
                if(!($SQLData.BrowserFirewall)){
                    if(!(Get-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser"))
                    {
                        New-FirewallRule -DisplayName "SQL Server Browser" -Service "SQLBrowser"
                    }
                }
            }
            "IS"
            {
                if(!($SQLData.IntegrationServicesFirewall)){
                    if(!(Get-FirewallRule -DisplayName "SQL Server Integration Services Application" -Application ((GetSQLPath -Feature "IS" -SQLVersion $SQLVersion) + "Binn\MsDtsSrvr.exe")))
                    {
                        New-FirewallRule -DisplayName "SQL Server Integration Services Application" -Application ((GetSQLPath -Feature "IS" -SQLVersion $SQLVersion) + "Binn\MsDtsSrvr.exe")
                    }
                    if(!(Get-FirewallRule -DisplayName "SQL Server Integration Services Port" -Port "TCP/135"))
                    {
                        New-FirewallRule -DisplayName "SQL Server Integration Services Port" -Port "TCP/135"
                    }
                }
            }
        }
    }

    if(!(Test-TargetResource -SourcePath $SourcePath -SourceFolder $SourceFolder -Features $Features -InstanceName $InstanceName))
    {
        throw New-TerminatingError -ErrorType TestFailedAfterSet -ErrorCategory InvalidResult
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [System.String]
        $SourcePath = "$PSScriptRoot\..\..\",

        [System.String]
        $SourceFolder = "Source",

        [parameter(Mandatory = $true)]
        [System.String]
        $Features,

        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $result = ((Get-TargetResource -SourcePath $SourcePath -SourceFolder $SourceFolder -Features $Features -InstanceName $InstanceName).Ensure -eq $Ensure)
    
    $result
}


function GetSQLVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    return (Get-Item -Path $Path).VersionInfo.ProductVersion.Split(".")[0]
}


function GetSQLPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Feature,
        
        [String]
        $InstanceName,

        [String]
        $SQLVersion
    )

    if(($Feature -eq "SQLENGINE") -or ($Feature -eq "AS"))
    {
        switch($Feature)
        {
            "SQLENGINE"
            {
                $RegSubKey = "SQL"
            }
            "AS"
            {
                $RegSubKey = "OLAP"
            }
        }
        $RegKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\$RegSubKey" -Name $InstanceName).$InstanceName
        $Path = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$RegKey\setup" -Name "SQLBinRoot")."SQLBinRoot"
    }

    if($Feature -eq "IS")
    {
        $Path = (Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\" + $SQLVersion + "0\DTS\setup") -Name "SQLPath")."SQLPath"
    }

    return $Path
}


function Get-FirewallRule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $DisplayName,

        [String]
        $Application,

        [String]
        $Service,

        [String]
        $Port
    )

    $Return = $false
    if($FirewallRule = Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue)
    {
        if(($FirewallRule.Enabled) -and ($FirewallRule.Profile -eq "Any") -and ($FirewallRule.Direction -eq "Inbound"))
        {
            if($PSBoundParameters.ContainsKey("Application"))
            {
                if($FirewallApplicationFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $FirewallRule -ErrorAction SilentlyContinue)
                {
                    if($FirewallApplicationFilter.Program -eq $Application)
                    {
                        $Return = $true
                    }
                }
            }
            if($PSBoundParameters.ContainsKey("Service"))
            {
                if($FirewallServiceFilter = Get-NetFirewallServiceFilter -AssociatedNetFirewallRule $FirewallRule -ErrorAction SilentlyContinue)
                {
                    if($FirewallServiceFilter.Service -eq $Service)
                    {
                        $Return = $true
                    }
                }
            }
            if($PSBoundParameters.ContainsKey("Port"))
            {
                if($FirewallPortFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $FirewallRule -ErrorAction SilentlyContinue)
                {
                    if(($FirewallPortFilter.Protocol -eq $Port.Split("/")[0]) -and ($FirewallPortFilter.LocalPort -eq $Port.Split("/")[1]))
                    {
                        $Return = $true
                    }
                }
            }
        }
    }
    return $Return
}


function New-FirewallRule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $DisplayName,

        [String]
        $Application,

        [String]
        $Service,

        [String]
        $Port
    )

    if($PSBoundParameters.ContainsKey("Application"))
    {
        New-NetFirewallRule -DisplayName $DisplayName -Enabled True -Profile Any -Direction Inbound -Program $Application
    }
    if($PSBoundParameters.ContainsKey("Service"))
    {
        New-NetFirewallRule -DisplayName $DisplayName -Enabled True -Profile Any -Direction Inbound -Service $Service
    }
    if($PSBoundParameters.ContainsKey("Port"))
    {
        New-NetFirewallRule -DisplayName $DisplayName -Enabled True -Profile Any -Direction Inbound -Protocol $Port.Split("/")[0] -LocalPort $Port.Split("/")[1]
    }
}


Export-ModuleMember -Function *-TargetResource
