configuration Sample_xPSEndpoint_NewWithDefaults
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name
    )

    Import-DscResource -module xPSDesiredStateConfiguration

    xPSEndpoint PSSessionConfiguration
    {
        Name = $Name
        Ensure = 'Present'
    }
}

configuration Sample_xPSEndpoint_LocalOnlyWorkflowEP
{
    Import-DscResource -module xPSDesiredStateConfiguration

    xPSEndpoint PSSessionConfiguration
    {
        Name       = 'Microsoft.PowerShell.Workflow'
        Ensure     = 'Present'
        AccessMode = 'Disabled'
    }
}

configuration Sample_xPSEndpoint_RemoveEP
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name
    )
    Import-DscResource -module xPSDesiredStateConfiguration

    xPSEndpoint PSSessionConfiguration
    {
        Name       = $Name
        Ensure     = 'Absent'
    }
}


configuration Sample_xPSEndpoint_NewWithRunAsandStartupAndCustomSDDLAndLocalAccess
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [PSCredential]$RunAs,

        [String]$SDDL = 'Default',

        [Parameter(Mandatory)]
        [String]$StartupScript
    )
    Import-DscResource -module xPSDesiredStateConfiguration

    Node 'localhost'
    {
        xPSEndpoint PSSessionConfiguration
        {
            Name                   = $Name
            Ensure                 = 'Present'
            AccessMode             = 'Local'
            RunAsCredential        = $RunAs
            SecurityDescriptorSDDL = $SDDL
            StartupScriptPath      = $StartupScript 
        }
    }
}

# To use the sample(s) with credentials, see blog at http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
