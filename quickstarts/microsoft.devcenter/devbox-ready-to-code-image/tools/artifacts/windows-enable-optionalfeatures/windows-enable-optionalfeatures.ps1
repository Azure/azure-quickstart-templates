param(
    [ValidateNotNullOrEmpty()]
    [string] $FeatureName
    
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$VerbosePreference = 'Continue'

Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -All