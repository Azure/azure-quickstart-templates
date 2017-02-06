<# 
Simple installer for an msi package that matches via the Name.
#>

param
(
    [String]$OutputPath = ".",

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $PackageName,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $SourcePath
)

Configuration Sample
{
    Import-DscResource -Module xPSDesiredStateConfiguration

    xPackage t1
    {
        Ensure="Present"
    Name = $PackageName
        Path = $SourcePath
        ProductId = ""
    }
}

<# 
Sample use (parameter values need to be changed according to your scenario):

# Create the MOF file using the configuration data
Sample -OutputPath $OutputPath -ConfigurationData $Global:AllNodes -PackageName "Package Name" -SourcePath "\\software\installer.msi"

#>
