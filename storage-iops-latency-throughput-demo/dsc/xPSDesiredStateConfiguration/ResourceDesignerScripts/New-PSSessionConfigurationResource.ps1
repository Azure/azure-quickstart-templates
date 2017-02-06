Import-Module -Name 'xDSCResourceDesigner'

$resProperties = @{
    Name          = New-xDscResourceProperty -Description 'Name of the PS Remoting Endpoint' `
                                             -Name Name -Type String -Attribute Key
    RunAsCred     = New-xDscResourceProperty -Description 'Credential for Running under different user context' `
                                             -Name RunAsCredential -Type PSCredential -Attribute Write
    SDDL          = New-xDscResourceProperty -Description 'SDDL for allowed users to connect to this endpoint. 'Default' means the default SDDL' `
                                             -Name SecurityDescriptorSDDL -Type String -Attribute Write
    StartupScript = New-xDscResourceProperty -Description 'Path for the startup script. Empty string clears the value'`
                                             -Name StartupScriptPath -Type String -Attribute Write
    Ensure        = New-xDscResourceProperty -Description 'Whether to create the endpoint or delete it' `
                                             -Name Ensure -Type String -Attribute Write -ValidateSet 'Present','Absent'
    AccessMode    = New-xDscResourceProperty -Description 'Whether the endpoint is remotely accessible or has local access only or no access' `
                                             -Name AccessMode -Type String -Attribute Write -ValidateSet 'Local','Remote', 'Disabled'
}

New-xDscResource -Name MSFT_xPSSessionConfiguration -Property $resProperties.Values -Path $home\desktop -ModuleName xPSDesiredStateConfiguration -FriendlyName xPSEndpoint -Force
