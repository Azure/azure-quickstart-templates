# This allows calling Build-DeploymentFile locally for debug.
# TODO: Turn this into a test.
$ENV:SAMPLE_FOLDER = Resolve-Path $ENV:SAMPLE_FOLDER
$ENV:SAMPLE_NAME = Split-Path (Resolve-Path $ENV:SAMPLE_FOLDER) -Leaf
$ENV:BUILD_REASON = "PullRequest"
$ENV:BICEP_PATH = "bicep"
$ENV:BICEP_VERSION = "1.2.3"
$ENV:BICEP_SUPPORTED = "true"

& "$PSScriptRoot/../ci-scripts/Build-DeploymentFile" `
    -MainTemplateFilenameBicep 'main.bicep' `
    -MainTemplateFilenameJson 'azuredeploy.json'
