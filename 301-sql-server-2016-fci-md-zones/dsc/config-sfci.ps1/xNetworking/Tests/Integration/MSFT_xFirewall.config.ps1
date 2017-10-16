<#
  This file exists so we can load the test file without necessarily having xNetworking in
  the $env:PSModulePath. Otherwise PowerShell will throw an error when reading the Pester File
#>

$rule = @{
    Name                  = 'b8df0af9-d0cc-4080-885b-6ed263aaed67'
    DisplayName           = 'Test Rule'
    Group                 = 'Test Group'
    Ensure                = 'Present'
    Enabled               = 'False'
    Profile               = @('Domain','Private')
    Action                = 'Allow'
    Description           = 'MSFT_xFirewall Test Firewall Rule'
    Direction             = 'Inbound'
    RemotePort            = @('8080', '8081')
    LocalPort             = @('9080', '9081')
    Protocol              = 'TCP'
    Program               = 'c:\windows\system32\notepad.exe'
    Service               = 'WinRM'
    Authentication        = 'NotRequired'
    Encryption            = 'NotRequired'
    InterfaceAlias        = (Get-NetAdapter -Physical | Select-Object -First 1).Name
    InterfaceType         = 'Wired'
    LocalAddress          = @('192.168.2.0-192.168.2.128','192.168.1.0/255.255.255.0')
    LocalUser             = 'Any'
    Package               = 'S-1-15-2-3676279713-3632409675-756843784-3388909659-2454753834-4233625902-1413163418'
    Platform              = @('6.1')
    RemoteAddress         = @('192.168.2.0-192.168.2.128','192.168.1.0/255.255.255.0')
    RemoteMachine         = 'Any'
    RemoteUser            = 'Any'
    DynamicTransport      = 'Any'
    EdgeTraversalPolicy   = 'Allow'
    LocalOnlyMapping      = $false
    LooseSourceMapping    = $false
    OverrideBlockRules    = $false
    Owner                 = (Get-CimInstance win32_useraccount | Select-Object -First 1).Sid
}

Configuration MSFT_xFirewall_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
       xFirewall Integration_Test {
            Name                  = $rule.Name
            DisplayName           = $rule.DisplayName
            Group                 = $rule.Group
            Ensure                = 'Present'
            Enabled               = $rule.Enabled
            Profile               = $rule.Profile
            Action                = $rule.Action
            Description           = $rule.Description
            Direction             = $rule.Direction
            RemotePort            = $rule.RemotePort
            LocalPort             = $rule.LocalPort
            Protocol              = $rule.Protocol
            Program               = $rule.Program
            Service               = $rule.Service
            Authentication        = $rule.Authentication
            Encryption            = $rule.Encryption
            InterfaceAlias        = $rule.InterfaceAlias
            InterfaceType         = $rule.InterfaceType
            LocalAddress          = $rule.LocalAddress
            LocalUser             = $rule.LocalUser
            Package               = $rule.Package
            Platform              = $rule.Platform
            RemoteAddress         = $rule.RemoteAddress
            RemoteMachine         = $rule.RemoteMachine
            RemoteUser            = $rule.RemoteUser
            DynamicTransport      = $rule.DynamicTransport
            EdgeTraversalPolicy   = $rule.EdgeTraversalPolicy
            LocalOnlyMapping      = $rule.LocalOnlyMapping
            LooseSourceMapping    = $rule.LooseSourceMapping
            OverrideBlockRules    = $rule.OverrideBlockRules
            Owner                 = $rule.Owner
        }
    }
}
