Configuration Example_xADRecycleBin
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $ForestFQDN,

    [parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $EACredential 
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADRecycleBin RecycleBin
        {
           EnterpriseAdministratorCredential = $EACredential
           ForestFQDN = $ForestFQDN
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = '2012r2-dc'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Example_xADRecycleBin -EACredential (Get-Credential contoso\administrator) -ForestFQDN 'contoso.com' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADRecycleBin -Wait -Verbose -WhatIf

Start-DscConfiguration -Path .\Example_xADRecycleBin -Wait -Verbose

