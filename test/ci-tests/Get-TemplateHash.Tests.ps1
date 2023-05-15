Describe "Get-TemplateHash" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/get-template-hash-tests"

        function Get-TemplateHash(
            [string][Parameter(Mandatory = $true)] $templateFilePath,
            [string]$bearerToken,
            [switch]$removeGeneratorMetadata
        ) {
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Get-TemplateHash.ps1".Replace('.Tests.ps1', '.ps1')
            . $cmdlet $templateFilePath $bearerToken -RemoveGeneratorMetadata:$removeGeneratorMetadata
        }
    }
    
    It 'Correctly removes metadata from all nested deployments before hashing' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/ModularTemplateWithMetadata.json" -RemoveGeneratorMetadata
        $hash2 = Get-TemplateHash "$dataFolder/ModularTemplateWithoutMetadata.json" -RemoveGeneratorMetadata

        $hash1 | Should -Be $hash2
    }

    It 'Correctly removes metadata before hashing' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/TemplateWithMetadata.json" -RemoveGeneratorMetadata
        $hash2 = Get-TemplateHash "$dataFolder/TemplateWithoutMetadata.json" -RemoveGeneratorMetadata

        $hash1 | Should -Be $hash2
    }

    It 'Shows a hash difference between bicep versions if not using RemoveGeneratorMetadata' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/TemplateWithMetadata.json"
        $hash2 = Get-TemplateHash "$dataFolder/TemplateWithoutMetadata.json"

        $hash1 | Should -Not -Be $hash2
    }

    It 'Shows hash difference when files differ outside of generator metadata' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/TemplateWithMetadata.json" -RemoveGeneratorMetadata
        $hash2 = Get-TemplateHash "$dataFolder/TemplateWithMetadataWithChanges.json" -RemoveGeneratorMetadata

        $hash1 | Should -Not -Be $hash2
    }
}