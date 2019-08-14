$releaseFiles = ".\ci-scripts", "template-tests", "..\Deploy-AzTemplate.ps1"

Compress-Archive -DestinationPath "AzTemplateToolKit.zip" -Path $releaseFiles

