<#
.Synopsis
    Checks the defaultValue of _artifactsLocation and _artifactsLocationSasToken parameters.
.Description
    Ensures that the artifacts parameters have correct defaults in all templates.  Be sure to set the values of the $SampleName and $RawRepoPath parameters if you
    are testing a code that is not going into the Azure Marketplace or QuickStart repo.
.Example
    Test-AzTemplate -TemplatePath .\100-marketplace-sample\ -Test artifacts-location-default-value
.Example
    .\artifacts-location-default-value.test.ps1 -TemplateObject (Get-Content ..\..\..\unit-tests\artifacts-location-default-value.json -Raw | ConvertFrom-Json) -IsMainTemplate
#>
param(
    [Parameter(Mandatory = $true)][PSObject]$TemplateObject,
    [Parameter(Mandatory = $true)][string]$TemplateFileName,
    [string]$SampleName = "$ENV:SAMPLE_NAME",
    [string]$RawRepoPath = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/",
    [switch]$IsMainTemplate
)

$artifactslocationParameter = $templateObject.parameters._artifactsLocation
$artifactslocationSasTokenParameter = $templateObject.parameters._artifactsLocationSasToken

#if there is no _artifactsLocationParameter skip the tests
if ($artifactslocationParameter -ne $null) {
    if ($artifactslocationParameter.type -ne "string") {
        Write-Error "The _artifactsLocation in `"$TemplateFileName`" parameter must be a 'string' type in the parameter delcaration `"$($artifactslocationParameter.type)`"" -ErrorId ArtifactsLocation.Parameter.TypeMisMatch -TargetObject $artifactslocationParameter
    }
    # is the sasToken present
    if ($artifactslocationSasTokenParameter -eq $null) {
        Write-Error "Template `"$TemplateFileName`" is missing _artifactsLocationSasToken parameter" -ErrorId ArtifactsLocation.Parameter.sasToken.Missing -TargetObject $artifactslocationParameter
    }
    elseif ($artifactslocationSasTokenParameter.type -ne "secureString") {
        Write-Error "The _artifactsLocationSasToken in `"$TemplateFileName`" parameter must be of type 'secureString'." -ErrorId ArtifactsLocation.Parameter.sasToken.TypeMisMatch -TargetObject $artifactslocationParameter        
    }
    # is the defaultValue correct
    if ($IsMainTemplate) {
        #in the main template defaultValue must exist and be correct
        if (-not $artifactslocationParameter.defaultValue) {
            # empty string is not ok
            Write-Error "The _artifactsLocation parameter in `"$TemplateFileName`" must have a defaultValue in the main template" -ErrorId ArtifactsLocation.Parameter.DefaultValue.Missing -TargetObject $artifactslocationParameter
        }
        else {
            # it must be one of two values
            $allowedDefaultValues = @("[deployment().properties.templateLink.uri]")
            if ([string]::IsNullOrWhiteSpace($SampleName)) {
                #if the sample folder is blank add a placeholder so manual inspection is possible
                $SampleName = "100-blank-template"
                Write-Warning "ENV:SAMPLE_NAME is empty - using placeholder for manual verification: $SampleName"
            }
            $allowedDefaultValues += "$RawRepoPath$SampleName/"
            # example: https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-automation-configuration/
            if (!($allowedDefaultValues -contains $artifactslocationParameter.defaultValue)) {
                Write-Error "The _artifactsLocation in `"$TemplateFileName`" has an incorrect defaultValue, found: $($artifactsLocationParameter.defaultValue)" -ErrorId ArtifactsLocation.Parameter.DefaultValue.Incorrect -TargetObject $artifactslocationParameter
                Write-Error "Must be one of: $allowedDefaultValues"
            }
        }
        if ( !($artifactslocationSasTokenParameter.defaultValue) -and $artifactslocationSasTokenParameter.defaultValue -ne "") {
            Write-Error "The _artifactsLocationSasToken in `"$TemplateFileName`" has an incorrect defaultValue, must be an empty string" -ErrorId ArtifactsLocation.Parameter.sasToken.DefaultValue.Incorrect -TargetObject $artifactslocationSasTokenParameter
        }
    }
    else {
        #if it's not main template, there must not be a defaultValue to ensure the value is passed through
        if ($artifactslocationParameter.defaultValue -or 
            $artifactslocationSasTokenParameter.defaultValue) {
            Write-Error "The _artifactsLocation and _artifactsLocationsSasToke parameters in `"$TemplateFileName`" must not have a defaulValue in a nested template." -ErrorId ArtifactsLocation.Parameter.DefaultValue.NotEmpty  
        }    
    } 
} # there is a parameter named _artifactsLocation