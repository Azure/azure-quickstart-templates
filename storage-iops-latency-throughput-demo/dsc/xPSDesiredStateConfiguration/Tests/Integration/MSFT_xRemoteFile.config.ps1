$TestConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "MSFT_xRemoteFile.config.ps1"
$TestURI = "file://$TestConfigPath"
$TestDestinationPath = Join-Path -Path $ENV:Temp -ChildPath "MSFT_xRemoteFile.config.ps1"

# Integration Test Config Template Version: 1.0.0
configuration MSFT_xRemoteFile_config {
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    node localhost {
        xRemoteFile Integration_Test {
            DestinationPath = $TestDestinationPath
            Uri = $TestURI
        }
    }
}
