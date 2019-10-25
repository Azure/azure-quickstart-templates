<#
.Synopsis
    Checks the defaultValue of _artifactsLocation parameters.
.Description
    Ensures that the artifacts parameters have correct defaults in all templates.
.Example
    Test-AzTemplate -TemplatePath .\100-marketplace-sample\ -Test artifacts-location-default-value
.Example
    .\artifacts-location-default-value.test.ps1 -TemplateObject (Get-Content ..\..\..\unit-tests\artifacts-location-default-value.json -Raw | ConvertFrom-Json) -IsMainTemplate
#>
param(
    [Parameter(Mandatory = $true)][PSObject]$TemplateObject,
    [Parameter(Mandatory=$true)][string]$TemplateFileName,
    [string]$SampleName = "$ENV:SAMPLE_NAME",
    [string]$RawRepoPath = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/",
    [switch]$IsMainTemplate
)

#get the parameters
Write-Output $TemplateFileName
Write-Output $SampleName
Write-Output $RawRepoPath$SampleName

$artifactslocationParameter = $templateObject.parameters._artifactsLocation
$artifactslocationSasTokenParameter = $templateObject.parameters._artifactsLocationSasToken

#if there is no _artifactsLocationParameter skip the tests
if ($artifactslocationParameter -ne $null) {
    if ($artifactslocationParameter.type -ne "string" -and $artifactslocationParameter.type -ne "secureString") {
        Write-Error "The _artifactsLocation in `"$TemplateFileName`" parameter must be a 'string' or 'secureString' type in the parameter delcaration `"$($artifactslocationParameter.type)`"" -ErrorId ArtifactsLocation.Parameter.TypeMisMatch -TargetObject $artifactslocationParameter
        
    }
    # is the sasToken present
    if ($artifactslocationSasTokenParameter -eq $null) {
        Write-Error "Template `"$TemplateFileName`" is missing _artifactsLocationSasToken parameter" -ErrorId ArtifactsLocation.Parameter.sasToken.Missing -TargetObject $artifactslocationParameter
        
    } elseif($artifactslocationSasTokenParameter.type -ne "secureString"){
        Write-Error "The _artifactsLocationSasToken in `"$TemplateFileName`" parameter must be of type 'secureString'." -ErrorId ArtifactsLocation.Parameter.sasToken.TypeMisMatch -TargetObject $artifactslocationParameter
        
    }
    # is the defaultValue correct
    if ($IsMainTemplate) {
        #in the main template defaultValue must exist and be correct
        if (-not $artifactslocationParameter.defaultValue) { # empty string is not ok
            Write-Error "The _artifactsLocation parameter in `"$TemplateFileName`" must have a defaultValue in the main template" -ErrorId ArtifactsLocation.Parameter.DefaultValue.Missing -TargetObject $artifactslocationParameter
            
        }
        else {
            # it must be one of two values
            $allowedDefaultValues = @("[deployment().properties.templateLink.uri]")
            if($SampleName -ne ""){ #if the sample folder is blank skip the test
                $allowedDefaultValues += "$RawRepoPath$SampleName/"
            }
            Write-Output $allowedDefaultValues
            # example: https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-automation-configuration/
            if (!($allowedDefaultValues -contains $artifactslocationParameter.defaultValue)) {
                Write-Error "The _artifactsLocation in `"$TemplateFileName`" has an incorrect defaultValue, found: $($artifactsLocationParameter.defaultValue)`nMust be one of: $allowedDefaultValues`nFound: `"$($artifactslocationParameter.defaultValue)`"" -ErrorId ArtifactsLocation.Parameter.DefaultValue.Incorrect -TargetObject $artifactslocationParameter
                
            }
        }
        if ( !($artifactslocationSasTokenParameter.defaultValue) -and $artifactslocationSasTokenParameter.defaultValue -ne ""){
            Write-Error "The _artifactsLocationSasToken in `"$TemplateFileName`" has an incorrect defaultValue, must be an empty string" -ErrorId ArtifactsLocation.Parameter.sasToken.DefaultValue.Incorrect -TargetObject $artifactslocationSasTokenParameter
            
        }
    }
    else {
        #if it's not main template, there must not be a defaultValue to ensure the value is passed through
        if ($artifactslocationParameter.defaultValue -or `
            $artifactslocationSasTokenParameter.defaultValue) {
            Write-Error "The _artifactsLocation and _artifactsLocationsSasToke parameters in `"$TemplateFileName`" must not have a defaulValue in a nested template." -ErrorId ArtifactsLocation.Parameter.DefaultValue.NotEmpty  
            
        }    
    } 
} # there is a parameter named _artifactsLocation