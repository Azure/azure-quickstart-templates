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
            $buildHostOutput = . $cmdlet `
                -SampleFolder $SampleFolder `
                -MainTemplateFilenameBicep ($bicepSupported ? $templateFileName : 'main.bicep') `
                -MainTemplateFilenameJson ($bicepSupported ? 'azuredeploy.json' : $templateFileName) `
                -BuildReason ($isPR ? 'PullRequest' : 'SomethingOtherThanPullRequest') `
                -BicepPath ($ENV:BICEP_PATH ? $ENV:BICEP_PATH : 'bicep') `
                -BicepVersion '1.2.3' `
                -bicepSupported:$bicepSupported `
                -ErrorAction 'ContinueSilently' `
                6>&1 2>&1 
            # Write-Host $buildHostOutput
            $ErrorActionPreference = 'Stop'
            $vars = Find-VarsFromWriteHostOutput $buildHostOutput
            $resultBicepBuild = $vars["RESULT_BICEP_BUILD"]

            $resultBicepBuild
        }
    }

    It 'gives FAIL status if bicep has errors' {
        $folder = "$dataFolder/bicep-error"
        $resultBicepBuild = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $resultBicepBuild | Should -Be "FAIL"
    }

    It 'gives FAIL status if bicep has linter warnings' {
        $folder = "$dataFolder/bicep-linter-warnings"
        $resultBicepBuild = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $resultBicepBuild | Should -Be "FAIL"
    }

    It 'gives FAIL status if bicep has compiler warnings' {
        $folder = "$dataFolder/bicep-compiler-warnings"
        $resultBicepBuild = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $resultBicepBuild | Should -Be "FAIL"
    }

    It 'gives empty status if not bicep' {
        $folder = "$dataFolder/json-success"
        $resultBicepBuild = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "azuredeploy.json"
        $resultBicepBuild | Should -Be $null
    }
    It 'gives success status if no errors' {
        $folder = "$dataFolder/bicep-success"
        $resultBicepBuild = Validate-DeploymentFile `
            -SampleFolder $folder `
            -TemplateFileName "main.bicep"
        $resultBicepBuild | Should -Be "PASS"
    }
}
