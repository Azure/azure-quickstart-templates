<# 
Simple installer that installs an msi package and matches based on the product id.
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
    [String] $ProductId
)

Configuration Sample
{
    Import-DscResource -Module xPSDesiredStateConfiguration

    xPackage t1
    {
        Ensure="Present"
    Name = $PackageName
        Path = $SourcePath
        ProductId = $ProductId
    }
}

<# 
Sample use (parameter values need to be changed according to your scenario):

# Create the MOF file using the configuration data
Sample -OutputPath $OutputPath -ConfigurationData $Global:AllNodes -PackageName "Package Name" -SourcePath "\\software\installer.msi" -ProductId "{F06FB2D7-C22C-4987-9545-7C3B15BBBD60}"


#>
