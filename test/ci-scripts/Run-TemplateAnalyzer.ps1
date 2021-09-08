<#

Downloads and runs TemplateAnalyzer against the nested templates, the pre requisites template, and the main deployment template, along with their parameters files

#>

param(
    [string] $ttkFolder = $ENV:TTK_FOLDER,
    [string] $templateAnalyzerReleaseUrl = $ENV:TEMPLATE_ANALYZER_RELEASE_URL,
    [string] $sampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $prereqTemplateFilename = $ENV:PREREQ_TEMPLATE_FILENAME_JSON, 
    [string] $prereqParametersFilename = $ENV:GEN_PREREQ_PARAMETERS_FILENAME,
    [string] $mainTemplateFilename = $ENV:MAINTEMPLATE_DEPLOYMENT_FILENAME,
    [string] $mainParametersFilename = $ENV:GEN_PARAMETERS_FILENAME
)

$RULE_FAILED_MESSAGE = "Result: Failed"

$templateAnalyzerFolderPath = "$ttkFolder\templateAnalyzer"
New-Item -ItemType Directory -Path $templateAnalyzerFolderPath -Force
Invoke-WebRequest -OutFile "$templateAnalyzerFolderPath\TemplateAnalyzer.zip" $templateAnalyzerReleaseUrl
Expand-Archive -LiteralPath "$templateAnalyzerFolderPath\TemplateAnalyzer.zip" -DestinationPath "$templateAnalyzerFolderPath"

# We don't want to run TTK checks by themselves and also in the TemplateAnalyzer integration
# Also, TemplateAnalyzer still doesn't support skipping tests like TTK
$ttkFolderInsideTemplateAnalyzer = "$templateAnalyzerFolderPath\TTK"
if (Test-Path $ttkFolderInsideTemplateAnalyzer) {
    Remove-Item -LiteralPath $ttkFolderInsideTemplateAnalyzer -Force -Recurse
}

$templateAnalyzer = "$templateAnalyzerFolderPath\TemplateAnalyzer.exe"
$testOutputFilePath = "$templateAnalyzerFolderPath\analysis_output.txt"
function Analyze-Template {
    param (
        $templateFilePath,
        $parametersFilePath
    )

    if ($templateFilePath -and (Test-Path $templateFilePath)) {
        $params = @{ "t" = $templateFilePath }
        if ($parametersFilePath -and (Test-Path $parametersFilePath)) {
            $params.Add("p", $parametersFilePath)
        } 
        $testOutput = & $templateAnalyzer @params
    }
    $testOutput = $testOutput -join "`n"

    if($testOutput.length -ne 0 -and $LASTEXITCODE -eq 0)
    {
        $testOutput >> $testOutputFilePath

        return $testOutput.Contains($RULE_FAILED_MESSAGE)
    } else {
        Write-Error "TemplateAnalyzer failed trying to analyze: $templateFilePath $parametersFilePath"
        exit 1
    }
}

$passed = $true
$preReqsFolder = "$sampleFolder\prereqs"
Get-ChildItem $sampleFolder -Recurse -Filter *.json |
    ForEach-Object {
        $params = @{ "templateFilePath" = $_.FullName }
        if ($_.FullName -eq "$preReqsFolder\$prereqTemplateFilename") {
            $params.Add("parametersFilePath", "$preReqsFolder\$prereqParametersFilename")
        } elseif ($_.FullName -eq "$sampleFolder\$mainTemplateFilename") {
            $params.Add("parametersFilePath", "$sampleFolder\$mainParametersFilename")
        }

        $newAnalysisPassed = Analyze-Template @params
        $passed = $passed -and $newAnalysisPassed # evaluation done in two lines to avoid PowerShell's lazy evaluation
    }

Write-Host "##vso[task.setvariable variable=template.analyzer.result]$passed"
Write-Host "##vso[task.setvariable variable=template.analyzer.output.filePath]$testOutputFilePath"

exit 0