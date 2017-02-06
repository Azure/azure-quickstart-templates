<# 
Simple package that installs an .exe using credentials to access the installer and specifying RunAs Credentials.

#>

param
(
    [String]$OutputPath = ".",

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $PackageName,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $SourcePath,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $ProductId,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $Credential,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $RunAsCredential

)

Configuration Sample
{
    Import-DscResource -Module xPSDesiredStateConfiguration

    xPackage t1
    {
        Ensure="Present"
     Name = $PackageName
        Path = $SourcePath
        RunAsCredential = $RunAsCredential
        Credential = $Credentials
        ProductId = $ProductId
    }
}

$Global:AllNodes=
@{
    AllNodes = @(     
                    @{
                        NodeName = "localhost";
                        RecurseValue = $true;
                     };                                                                                     
                );    
}

<# 
Sample use (parameter values need to be changed according to your scenario):

# Create the MOF file using the configuration data
Sample -OutputPath $OutputPath -ConfigurationData $Global:AllNodes -PackageName "Package Name" -SourcePath "\\software\installer.exe" -ProductId "" `
    -Credential $Credential -RunAsCredential $RunAsCredential

#>

