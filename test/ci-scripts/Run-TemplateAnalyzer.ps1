<#

Downloads and runs TemplateAnalyzer against the pre requisites template, and the main deployment template, along with all the parameters files

#>

param(
    [string] $ttkFolder = $ENV:TTK_FOLDER, # TODO ask
    [string] $sampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $prereqTemplateFilename = $ENV:PREREQ_TEMPLATE_FILENAME_JSON, 
    [string] $prereqParametersFilename = $ENV:PREREQ_PARAMETERS_FILENAME_JSON, # TODO ask
    [string] $mainTemplateFilename = $ENV:MAINTEMPLATE_DEPLOYMENT_FILENAME
    # [string[]] $ttkTestsToSkip = $ENV:TTK_SKIP_TESTS TODO ask
)

$RULE_FAILED_MESSAGE = "Result: Failed"

$templateAnalyzerFolderPath = "$ttkFolder\templateAnalyzer"
New-Item -ItemType Directory -Path $templateAnalyzerFolderPath -Force
Invoke-WebRequest -OutFile "$templateAnalyzerFolderPath\TemplateAnalyzer.zip" https://github.com/Azure/template-analyzer/releases/download/0.0.2-alpha/TemplateAnalyzer.zip
# ^ will be replaced by https://github.com/Azure/template-analyzer/releases/latest/download/TemplateAnalyzer.zip after CLI changes are released
Expand-Archive -LiteralPath "$templateAnalyzerFolderPath\TemplateAnalyzer.zip" -DestinationPath "$templateAnalyzerFolderPath"
$templateAnalyzerPath = "$templateAnalyzerFolderPath\TemplateAnalyzer.exe"
Write-Host "##vso[task.setvariable variable=TemplateAnalyzer.path]$templateAnalyzerPath"

$templateAnalyzerVersion = & $templateAnalyzerPath --version
Write-Host "##vso[task.setvariable variable=TemplateAnalyzer.version]$templateAnalyzerVersion"

function Analyze-Template {
    param (
        $templateFileName,
        $parametersFileName,
        $testName
    )

    if ($templateFileName -and (Test-Path $templateFileName)) {
        $params = @{ "t" = $templateFileName }
        if ($parametersFileName -and (Test-Path $parametersFileName)) {
            $params.Add("p", $parametersFileName)
        } 
        $testOutput = & $templateAnalyzerPath @params
    }
    $testOutput = $testOutput -join "`n"

    if($testOutput.length -ne 0 -and $LASTEXITCODE -eq 0)
    {
        $testOutput >> "$templateAnalyzerFolderPath\analysis_output.txt"
        Write-Host "##vso[task.setvariable variable=TemplateAnalyzer.$testName.ran]$true"
        Write-Host ("##vso[task.setvariable variable=TemplateAnalyzer.$testName.reportedErrors]" + $testOutput.Contains($RULE_FAILED_MESSAGE))
    } else {
        exit 1 # TODO ask
    }
}

Analyze-Template $prereqTemplateFilename $prereqParametersFilename "preReqs"

$newTemplateParametersFile = "$sampleFolder\azuredeploy.parameters.new.json" # TODO ask
Analyze-Template $mainTemplateFilename $newTemplateParametersFile "mainTemplate"

exit 0 # TODO ask