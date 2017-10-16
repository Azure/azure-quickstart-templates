# DSC configuration for Firewall
#

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
            Name                  = "NotePadFirewallRule"
            DisplayName           = "Firewall Rule for Notepad.exe"
            Group                 = "NotePad Firewall Rule Group"
            Ensure                = "Present"
            Description           = "Firewall Rule for Notepad.exe"
            Program               = "c:\windows\system32\notepad.exe"
        }
    }
 }
