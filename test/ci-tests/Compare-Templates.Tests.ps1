Describe "Compare-Templates" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/get-template-hash-tests"

        function Compare-Templates(
            [string][Parameter(mandatory = $true)] $templateFilePathExpected,
            [string][Parameter(mandatory = $true)] $templateFilePathActual,
            [switch][Parameter(Mandatory = $false)] $removeGeneratorMetadata
        ) {
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Compare-Templates.ps1".Replace('.Tests.ps1', '.ps1')
            . $cmdlet $templateFilePathExpected $templateFilePathActual -removeGeneratorMetadata:$removeGeneratorMetadata -WriteToHost
        }
    }

    It 'Recognizes when templates are different' {
        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithMetadataWithChanges.json"

        $same | Should -Be $false
    }

    It 'Shows difference when files differ outside of generator metadata with or without using -RemoveGeneratorMetadata' {
        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithMetadataWithChanges.json"
        $same | Should -Be $false

        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithMetadataWithChanges.json" -RemoveGeneratorMetadata
        $same | Should -Be $false
    }

    It 'Recognizes when templates are same except for metadata' {
        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithoutMetadata.json" -RemoveGeneratorMetadata

        $same | Should -Be $true
    }

    It 'Recognizes when templates are same except for metadata with nested templates' {
        $same = Compare-Templates "$dataFolder/ModularTemplateWithMetadata.json" "$dataFolder/ModularTemplateWithoutMetadata.json" -RemoveGeneratorMetadata

        $same | Should -Be $true
    }

    It 'Shows a hash difference between bicep versions only if not using -RemoveGeneratorMetadata' {
        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithoutMetadata.json"
        $same | Should -Be $false

        $same = Compare-Templates "$dataFolder/TemplateWithMetadata.json" "$dataFolder/TemplateWithoutMetadata.json" -RemoveGeneratorMetadata
        $same | Should -Be $true
    }
}