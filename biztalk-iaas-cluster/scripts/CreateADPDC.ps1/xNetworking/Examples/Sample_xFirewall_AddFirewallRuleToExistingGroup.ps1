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
            DisplayGroup          = "My Firewall Rule Group"
	        Access                = "Allow"
        }

        xFirewall Firewall1
        {
            Name                  = "MyFirewallRule1"
            DisplayName           = "My Firewall Rule"
            DisplayGroup          = "My Firewall Rule Group"
            Ensure                = "Present"
            Access                = "Allow"
            State                 = "Enabled"
            Profile               = ("Domain", "Private")
        }
    }
 }