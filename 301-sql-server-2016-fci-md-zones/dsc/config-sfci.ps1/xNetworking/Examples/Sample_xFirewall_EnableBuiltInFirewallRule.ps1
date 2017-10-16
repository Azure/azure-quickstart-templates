# DSC configuration that enables the built-in Firewall Rule
# 'World Wide Web Services (HTTP Traffic-In)'

configuration Sample_xFirewall_EnableBuiltInFirewallRule
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "IIS-WebServerRole-HTTP-In-TCP"
            Ensure                = "Present"
            Enabled               = "True"
        }
    }
 }

Sample_xFirewall_EnableBuiltInFirewallRule
Start-DscConfiguration -Path Sample_xFirewall_EnableBuiltInFirewallRule -Wait -Verbose -Force
