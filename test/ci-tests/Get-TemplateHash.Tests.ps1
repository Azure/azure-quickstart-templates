Describe "Get-TemplateHash" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/get-template-hash-tests"

        function Get-TemplateHash(
            [string][Parameter(Mandatory = $true)] $templateFilePath,
            [string]$bearerToken
        ) {
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Get-TemplateHash.ps1".Replace('.Tests.ps1', '.ps1')
            . $cmdlet $templateFilePath $bearerToken
        }
    }
    
    It 'Correctly removes metadata before hashing' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/TemplateWithHash.json"
        $hash2 = Get-TemplateHash "$dataFolder/TemplateWithoutHash.json"

        $hash1 | Should -Be $hash2
    }

    It 'Shows hash difference when files differ outside of generator metadata' {
        # hash with and without metadata should be the same
        $hash1 = Get-TemplateHash "$dataFolder/TemplateWithHash.json"
        $hash2 = Get-TemplateHash "$dataFolder/TemplateWithHashWithChanges.json"

        $hash1 | Should -Not -Be $hash2
    }
}