<#
This sample DSC Resource allows you to configure the Remote Desktop settings (under Remote Settings).
Leveraging the xFirewall resource (included in MSFT_xNetworking), firewall rules can also be configured.
Leveraging the Group resource (included in Windows), the "Remote Desktop Users" group can also be configured.
This sample has been tested with Windows Server 2012 R2 and WMF 5.0 Preview
Author: Tiander Turpijn, Microsoft Corporation

Used parameters:
Ensure [string] translates to reg value fDenyTSConnections [Int] - Allow RDP connection: Present = 0 "Enabled", Absent = 1 "Disabled"
UserAuthentication [string] translates to reg value UserAuthentication [Int] - Allow only Network Level Authentication - connections: Secure = 1 "Secure", NonSecure = 0 "NonSecure"
#>

#region GET RDP Settings
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [ValidateSet("NonSecure", "Secure")]
        [System.String]$UserAuthentication
    )

    switch ($Ensure) {
        "Present" {[System.Byte]$fDenyTSConnections = 0}
        "Absent" {[System.Byte]$fDenyTSConnections = 1}
        }

    switch ($UserAuthentication) {
        "NonSecure" {[System.Byte]$UserAuthentication = 0}
        "Secure" {[System.Byte]$UserAuthentication = 1}
        }    

    $GetDenyTSConnections = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
    $GetUserAuth = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication"

        $returnValue = @{
            Ensure = switch ($GetDenyTSConnections.fDenyTSConnections) {
                                    0 {"Present"}
                                    1 {"Absent"}
                                    }
            UserAuthentication =     switch ($GetUserAuth.UserAuthentication) {
                                        0 {"NonSecure"}
                                        1 {"Secure"}
                                        } 
            }
    
    $returnValue
    }

#  Get-TargetResource 'Present' 'Secure' -Verbose
#  Expectation is a hashtable with configuration of the machine.

#endregion

#region SET RDP Settings
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [ValidateSet("NonSecure", "Secure")]
        [System.String]$UserAuthentication
    )

    switch ($Ensure) {
        "Present" {[System.Byte]$fDenyTSConnections = 0}
        "Absent" {[System.Byte]$fDenyTSConnections = 1}
        }

    switch ($UserAuthentication) {
        "NonSecure" {[System.Byte]$UserAuthentication = 0}
        "Secure" {[System.Byte]$UserAuthentication = 1}
        }  

    $GetEnsure = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
    $GetUserAuthentiation = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication").UserAuthentication
    
    #The make it so section
    if ($fDenyTSConnections -ne $GetEnsure) {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value $fDenyTSConnections        
        }
    if ($UserAuthentication -ne $GetUserAuthentication) {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value $UserAuthentication
        }
    }

#  Set-TargetResource 'Present' 'Secure' -Verbose
#  Expectation is the computer will be configured to accept secure RDP connections.  To verify, right click on the Windows button and open System - Remote Settings.

#endregion

#region TEST RDP Settings
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [ValidateSet("NonSecure", "Secure")]
        [System.String]$UserAuthentication
    )

    switch ($Ensure) {
        "Present" {[System.Byte]$fDenyTSConnections = 0}
        "Absent" {[System.Byte]$fDenyTSConnections = 1}
        }

    switch ($UserAuthentication) {
        "NonSecure" {[System.Byte]$UserAuthentication = 0}
        "Secure" {[System.Byte]$UserAuthentication = 1}
        } 

    $GetfDenyTSConnections = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
    $GetUserAuthentiation = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication").UserAuthentication
    
    $bool = $false

    if ($fDenyTSConnections -eq $GetfDenyTSConnections -and $UserAuthentication -eq $GetUserAuthentiation)
        {
            Write-Verbose "RDP settings are matching the desired state"
            $bool = $true
        }
    else
        {
            Write-Verbose "RDP settings are Non-Compliant!"
            if ($fDenyTSConnections -ne $GetfDenyTSConnections) {
                    Write-Verbose "DenyTSConnections settings are non-compliant, Value should be $fDenyTSConnections - Detected value is: $GetfDenyTSConnections"   
                    }
            if ($UserAuthentication -ne $GetUserAuthentiation) {
                    Write-Verbose "UserAuthentication settings are non-compliant, Value should be $UserAuthentication - Detected value is: $GetUserAuthentiation" 
                    }
        }
    
    $bool
    }

#  Test-TargetResource 'Present' 'Secure' -Verbose
#  Expectation is a true/false output based on whether the machine matches the declared configuration.

#endregion


Export-ModuleMember -Function *-TargetResource

