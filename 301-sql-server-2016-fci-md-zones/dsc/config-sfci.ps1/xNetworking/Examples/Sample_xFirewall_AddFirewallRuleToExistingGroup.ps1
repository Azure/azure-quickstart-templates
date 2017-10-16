# DSC configuration for Firewall
#

configuration Sample_xFirewall_AddFirewallRuleToExistingGroup
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
            Name                  = "MyFirewallRule"
            DisplayName           = "My Firewall Rule"
            Group                 = "My Firewall Rule Group"
        }

        xFirewall Firewall1
        {
            Name                  = "MyFirewallRule1"
            DisplayName           = "My Firewall Rule"
            Group                 = "My Firewall Rule Group"
            Ensure                = "Present"
            Enabled               = "True"
            Profile               = ("Domain", "Private")
        }
    }
 }
