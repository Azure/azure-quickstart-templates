Configuration cChocoPackageInstallerSet
{
<#
.SYNOPSIS
Composite DSC Resource allowing you to specify multiple choco packages in a single resource block.
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Name,
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure='Present',
		[parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Source
    )

    $addSource = $Source

    foreach ($pName in $Name) {
        ## We only need to specify the source one time,
        ## so we do it only with the first package
        if ($addSource) {
            cChocoPackageInstaller "cChocoPackageInstaller_$($Ensure)_$($pName)" {
                Ensure = $Ensure
                Name = $pName
                Source = $Source
            }
            $addSource = $null
        }
        else {
            cChocoPackageInstaller "cChocoPackageInstaller_$($Ensure)_$($pName)" {
                Ensure = $Ensure
                Name = $pName
            }
        }
    }
}
