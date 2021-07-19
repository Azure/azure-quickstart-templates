
#test
#$invocation = $MyInvocation.MyCommand.Path
#$directorypath = Split-Path $invocation
#$templateFilePath=$directorypath+"\..\.m2/deploy.Json"
$templateFilePath="C:\Users\s9zcbg\.m2\deploy.Json"



New-AzureRmResourceGroupDeployment -Name "servicealert" -ResourceGroupName "madhantest" -TemplateFile $templateFilePath
