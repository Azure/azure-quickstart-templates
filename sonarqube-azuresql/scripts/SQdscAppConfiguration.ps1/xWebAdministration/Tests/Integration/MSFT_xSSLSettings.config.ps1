#requires -Version 4

configuration MSFT_xSSLSettings_Present
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName
    {  
        xSSLSettings Website
        {
            Ensure = 'Present'
            Name = $Node.Website
            Bindings = $Node.Bindings
        }
    }
}

configuration MSFT_xSSLSettings_Absent
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName 
    {  
        xSSLSettings Website
        {
            Ensure = 'Absent'
            Name = $Node.Website
            Bindings = ''
        }
    }
}
