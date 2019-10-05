param(
    [switch]$IsMainTemplate
)

<#
    Use this table to make sure all the tests are covered, since different templates will be required.

    =============================================================
    Test Case                 | main template | nested template |
    ==========================|===============|=================|
    defaultValue-deployment() |       0(pass) |        0(pass)  |
    defaultValue-raw github   |       1(pass) |        0(pass)  |
    defaultValue-missing      |       2       |        0(pass)  |
    defaultValue-invalid      |       3       |        2        |
    missing sas param         |       4       |        1        |
    typeMismatch location     |       5       |        3        |
    typeMismatch sas          |       5       |        3        |
    =============================================================

#>



$mainTemplateTests = @(
    ".\main-artifacts.0.json",
    ".\main-artifacts.1.json",
    ".\main-artifacts.2.json",
    ".\main-artifacts.3.json",
    ".\main-artifacts.4.json",
    ".\main-artifacts.5.json"
)

$nestedTemplateTests = @(
    ".\nested-artifacts.0.json",
    ".\nested-artifacts.1.json",
    ".\nested-artifacts.2.json",
    ".\nested-artifacts.3.json"
)

if ($IsMainTemplate) { $TestsToRun = $mainTemplateTests }
else { $TestsToRun = $nestedTemplateTests }

foreach ($t in $TestsToRun) {
    $TemplateObject = Get-Content -path $t -raw | ConvertFrom-Json
    $TemplateFileName = $t.Replace(".\", "")
    $SampleName = "101-automation-configuration" # this needs to match the value in the test
    if($IsMainTemplate){
        & ..\..\template-tests\testcases\deploymentTemplate\artifacts-parameter.test.ps1 -TemplateObject $TemplateObject -TemplateFileName $TemplateFileName -SampleName $SampleName -IsMainTemplate
    } else {
        & ..\..\template-tests\testcases\deploymentTemplate\artifacts-parameter.test.ps1 -TemplateObject $TemplateObject -TemplateFileName $TemplateFileName -SampleName $SampleName
    }
}
