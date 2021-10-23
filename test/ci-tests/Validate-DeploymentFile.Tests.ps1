Describe "Validate-DeploymentFile" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/validate-deploymentfile-tests"

        Import-Module "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Local.psm1" -Force
        
        function Validate-DeploymentFile(
            [string][Parameter(Mandatory = $true)]$SampleFolder,
            [string][Parameter(Mandatory = $true)]$TemplateFileName,
            [switch]$isPR
        ) {
            $bicepSupported = $templateFileName.EndsWith('.bicep')
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Validate-DeploymentFile.ps1"
            $ErrorActionPreference = 'ContinueSilently'
            $err = $null
            $warn = $null
            $Error.Clear()
            $buildHostOutput = . $cmdlet `
                -SampleFolder $SampleFolder `
                -MainTemplateFilenameBicep ($bicepSupported ? $templateFileName : 'main.bicep') `
                -MainTemplateFilenameJson ($bicepSupported ? 'azuredeploy.json' : $templateFileName) `
                -BuildReason ($isPR ? 'PullRequest' : 'SomethingOtherThanPullRequest') `
                -BicepPath ($ENV:BICEP_PATH ? $ENV:BICEP_PATH : 'bicep') `
                -BicepVersion '1.2.3' `
                -bicepSupported:$bicepSupported `
                -ErrorVariable err `
                -ErrorAction SilentlyContinue `
                -WarningVariable warn `
                6>&1 2>$null 3>$null
            # Write-Host $buildHostOutput
            $ErrorActionPreference = 'Stop'
            $vars = Find-VarsFromWriteHostOutput $buildHostOutput
            $labelBicepWarnings = $vars["LABEL_BICEP_WARNINGS"] -eq "True"
            $hasErrors = $err.Count -gt 0
            $hasWarnings = $warn.Count -gt 0

            $hasErrors, $hasWarnings, $labelBicepWarnings
        }
    }

    It 'bicep has no errors' {
        $folder = "$dataFolder/bicep-success"
        $hasErrors, $hasWarnings, $labelBicepWarnings = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $hasErrors | Should -Be $false
        $hasWarnings | Should -Be $false
        $labelBicepWarnings | Should -Be $false    
    }

    It 'bicep has errors and warnings' {
        $folder = "$dataFolder/bicep-error"
        $hasErrors, $hasWarnings, $labelBicepWarnings = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $hasErrors | Should -Be $true
        $hasWarnings | Should -Be $true
        $labelBicepWarnings | Should -Be $false # We only show the label if the build succeeds (no errors)
    }

    It 'bicep has linter warnings' {
        $folder = "$dataFolder/bicep-linter-warnings"
        $hasErrors, $hasWarnings, $labelBicepWarnings = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $hasErrors | Should -Be $false
        $hasWarnings | Should -Be $true
        $labelBicepWarnings | Should -Be $true
    }

    It 'bicep has compiler warnings' {
        $folder = "$dataFolder/bicep-compiler-warnings"
        $hasErrors, $hasWarnings, $labelBicepWarnings = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $hasErrors | Should -Be $false
        $hasWarnings | Should -Be $true
        $labelBicepWarnings | Should -Be $true
    }

    It 'not bicep' {
        $folder = "$dataFolder/json-success"
        $hasErrors, $hasWarnings, $labelBicepWarnings = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "azuredeploy.json"
        $hasErrors | Should -Be $false
        $hasWarnings | Should -Be $false
        $labelBicepWarnings | Should -Be $false
    }
}
