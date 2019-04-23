param(
[Parameter(Mandatory=$true)]
[PSObject]
$TemplateObject
)
foreach ($resource in $templateObject.resources) {
    # This is a PowerShell trick to simplify multiple -ors
    # -notcontains checks that a list (on the left side) doesn't contain a value (on the right side)
    # So this test will ignore resources that aren't /virtualmachines or /virtualmachineassets
    if ('microsoft.compute/virtualmachinescalesets', 
        'microsoft.compute/virtualmachines' -notcontains $resource.ResourceType) {
        continue
    }
    $imageReference = $resource.virtualmachineprofile.storageprofile.imagereference
    if (-not $imageReference) {
        Write-Error "Virtual machine resource $($resource.Name) has no image to reference" -TargetObject $resource -ErrorId VM.Missing.Image
    }

    if ($imageReference -like '*-preview') {
        Write-Error "Virtual machine resource $($resource.Name) must not use a preview image" -TargetObject $ResourceType -ErrorId VM.Using.Preview.Image
    }
}