Describe "Validate-DeploymentFile" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/validate-deploymentfile-tests"

        function Validate-DeploymentFile(
            [string][Parameter(Mandatory = $true)]$SampleFolder,
            [string][Parameter(Mandatory = $true)]$templateFileName,
            [switch]$isPR
        ) {
            $bicepSupported = $templateFileName.EndsWith('.bicep')
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Validate-DeploymentFile.ps1"            
            . $cmdlet `
                -SampleFolder $SampleFolder `
                -MainTemplateFilenameBicep ($bicepSupported ? $templateFileName : 'main.bicep') `
                -MainTemplateFilenameJson ($bicepSupported ? 'azuredeploy.json' : $templateFileName) `
                -BuildReason ($isPR ? 'PullRequest' : 'SomethingOtherThanPullRequest') `
                -BicepPath ($ENV:BICEP_PATH ? $ENV:BICEP_PATH : 'bicep') `
                -BicepVersion '1.2.3' `
                -bicepSupported $bicepSupported        
        }
    }
    
    # TODO
    # It 'asdf' {
    #     $SampleFolder = "$dataFolder/missing-apiversion-types" 
    #     $templateFileName = "missing-apiversion-types1.bicep"
    #     $a = Validate-DeploymentFile $SampleFolder $templateFileName -outvariable $warnings 2>&1

    #     $errors | Should -Be ""
    #     $warnings | Should -Be ""
    # }
}