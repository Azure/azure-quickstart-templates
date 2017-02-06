<# 
Simple package that installs an .exe using credentials to access the installer and specifying RunAs Credentials.
This sample also uses custom registry data to discover the package.

#>
param
(
    [String]$OutputPath = ".",

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Package,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Source,

    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [String] $ProductId,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $InstalledCheckRegKey,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $InstalledCheckRegValueName,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $InstalledCheckRegValueData,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $Credential,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $RunAsCredential,

    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [PSCredential] $Arguments
)

Configuration Sample
{
    Import-DscResource -Module xPSDesiredStateConfiguration

    xPackage t1
    {
        Ensure="Present"
     Name = $Package
        Path = $Source
        Arguments = $Arguments
        RunAsCredential = $RunAsCredential
        Credential = $Credential
        ProductId = $ProductId
        InstalledCheckRegKey = $InstalledCheckRegKey
        InstalledCheckRegValueName = $InstalledCheckRegValueName
        InstalledCheckRegValueData = $InstalledCheckRegValueData
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
Sample -OutputPath $OutputPath -ConfigurationData $Global:AllNodes -Package "Package Name" -Source "\\software\installer.exe" `
    -InstalledCheckRegKey "SOFTWARE\Microsoft\DevDiv\winexpress\Servicing\12.0\coremsi" `
    -InstalledCheckRegValueName "Install" -InstalledCheckRegValueData "1" `
    -Credential $Credential -RunAsCredential $RunAsCredential `
    -Arguments "/q" -ProductId ""

#>
