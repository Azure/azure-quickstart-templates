<#

Downloads and runs TemplateAnalyzer against the nested templates, the pre requisites template, and the main deployment template, along with their parameters files

#>

param(
    [string] $ttkFolder = $ENV:TTK_FOLDER, # TODO ask
    [string] $sampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $prereqTemplateFilename = $ENV:PREREQ_TEMPLATE_FILENAME_JSON, 
    [string] $prereqParametersFilename = $ENV:PREREQ_PARAMETERS_FILENAME_JSON, # TODO ask
    [string] $mainTemplateFilename = $ENV:MAINTEMPLATE_DEPLOYMENT_FILENAME
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

# We don't want to run TTK checks by themselves and also in the TemplateAnalyzer integration
# Also, TemplateAnalyzer still doesn't support skipping tests like TTK
$ttkFolderInsideTemplateAnalyzer = "$templateAnalyzerFolderPath\TTK"
if (Test-Path $ttkFolderInsideTemplateAnalyzer) {
    Remove-Item -LiteralPath $ttkFolderInsideTemplateAnalyzer -Force -Recurse
}

$testOutputFilePath = "$templateAnalyzerFolderPath\analysis_output.txt"
function Analyze-Template {
    param (
        $templateFileName,
        $parametersFileName
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
        $testOutput >> $testOutputFilePath

        return $testOutput.Contains($RULE_FAILED_MESSAGE)
    } else {
        exit 1 # TODO ask
    }
}

$reportedErrors = $false
Get-ChildItem $sampleFolder -Directory | # To analyze all the JSON files in folders that could contain nested templates
    ForEach-Object {
        Get-ChildItem $_ -Recurse -Filter *.json |
            ForEach-Object {
                $reportedErrors = $reportedErrors -or (Analyze-Template $_.FullName)
            }
    }
$reportedErrors = $reportedErrors -or (Analyze-Template $prereqTemplateFilename $prereqParametersFilename)
$reportedErrors = $reportedErrors -or (Analyze-Template $mainTemplateFilename "$sampleFolder\azuredeploy.parameters.new.json") # TODO ask about params file

Write-Host "##vso[task.setvariable variable=TemplateAnalyzer.reportedErrors]$reportedErrors"
Write-Host "##vso[task.setvariable variable=TemplateAnalyzer.output.filePath]$testOutputFilePath"

exit 0 # TODO ask