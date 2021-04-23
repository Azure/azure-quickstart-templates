# DSC configuration for Firewall

configuration Sample_xFirewall_AddFirewallRuleToNewGroup
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
            Name                  = "MyAppFirewallRule"            
            ApplicationPath       = "c:\windows\system32\MyApp.exe"
	        Access                = "Allow"
        }
    }
 }