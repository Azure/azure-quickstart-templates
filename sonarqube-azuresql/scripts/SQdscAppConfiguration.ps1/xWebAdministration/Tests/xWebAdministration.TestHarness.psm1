function Invoke-xWebAdministrationTests() {
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String] $TestResultsFile,
        
        [Parameter(Mandatory = $false)]
        [System.String] $DscTestsPath
    )

    Write-Verbose 'Commencing xWebAdministration unit tests'

    $repoDir = Join-Path $PSScriptRoot '..' -Resolve

    $testCoverageFiles = @()
    Get-ChildItem "$repoDir\DSCResources\**\*.psm1" -Recurse | ForEach-Object { 
        if ($_.FullName -notlike '*\DSCResource.Tests\*') {
            $testCoverageFiles += $_.FullName    
        }
    }

    $testResultSettings = @{ }
    if ([String]::IsNullOrEmpty($TestResultsFile) -eq $false) {
        $testResultSettings.Add('OutputFormat', 'NUnitXml' )
        $testResultSettings.Add('OutputFile', $TestResultsFile)
    }
    
    Import-Module "$repoDir\xWebAdministration.psd1"
    
    $versionsToTest = (Get-ChildItem (Join-Path $repoDir '\Tests\Unit\')).Name
    
    $testsToRun = @()
    $versionsToTest | ForEach-Object {
        $testsToRun += @(@{
                'Path' = "$repoDir\Tests\Unit\$_"
        })
    }
    
    if ($PSBoundParameters.ContainsKey('DscTestsPath') -eq $true) {
        $testsToRun += @{
            'Path' = $DscTestsPath
        }
    }

    $results = Invoke-Pester -Script $testsToRun -CodeCoverage $testCoverageFiles -PassThru @testResultSettings

    return $results

}
