<# 

This script recursively calls the Kill-AzResourceGroup.ps1 script to remove any resourceGroups that failed deletion previous.
Some resource cannot be deleted until hours after they are created

$x = Get-AzResourceGroup | Select ResourceGroupName
foreach($rg in $x){
$o = "'" + $rg.ResourceGroupName + "',"
Write-Host $o
}

$rgs = @( ... )

#>

param(
    [string] $TTKPath = ".",
    [long] $SleepTime = 600,
    [string] $ResourceGroupName, # if a single name is passed, use it
    [array] $ResourceGroupNames, # if an array is passed, use it
    [string] $Pattern = "azdo-*" # else use the default pattern
)

$azdoResourceGroups = @()

# TODO - this create noise in the log but is probably helpful to check once in a while - we disable here so running the nested script will still show them
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

if ($ResourceGroupNames.count -ne 0) {
    foreach ($rgName in $ResourceGroupNames) {
        $azdoResourceGroups += @{"ResourceGroupName" = $rgName }
    }
    $SecondErrorAction = "SilentlyContinue"
}
elseif (![string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    $azdoResourceGroups += @{"ResourceGroupName" = $ResourceGroupName }
    $SecondErrorAction = "Continue"
}
else {
    #if a RG name was not passed remove all with the CI pattern
    $azdoResourceGroups = get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like $Pattern }
    $SecondErrorAction = "SilentlyContinue"
}

foreach ($rg in $azdoResourceGroups) {
    
    Write-Host "***********************"
    Write-Host "  $(Get-Date)"
    Write-Host "***********************"

    # remove the resource group
    $bypassTag = $(Get-AzTag -ResourceId $rg.ResourceId).properties.tagsproperty.bypass
    # skip resourece groups that have been tagged due to some bug and can't be deleted
    # this enables getting to the other resourceGroups instead of timing out
    if (!$bypassTag) {
        Write-Host "First attempt on ResourceGroup: $($rg.ResourceGroupName)"
        Write-Host "--------------------------------------------------------------------------"
        & $TTKPath/ci-scripts/Kill-AzResourceGroup.ps1 -ResourceGroupName ($rg.ResourceGroupName) -Verbose -ErrorAction SilentlyContinue

        # if the resource group still exists after the first attempt, try again after a few minutes
        Write-Host "Checking for ResourceGroup: $($rg.ResourceGroupName)"
        if ((Get-AzResourceGroup -Name $rg.ResourceGroupName -verbose -ErrorAction SilentlyContinue) -ne $null) {
            Write-Host "Found the resource group - sleeping..." 
            Start-Sleep $SleepTime
            Write-Host "Second Attempt on ResourceGroup: $($rg.ResourceGroupName)"
            Write-Host "--------------------------------------------------------------------------"
            & $TTKPath/ci-scripts/Kill-AzResourceGroup.ps1 -ResourceGroupName ($rg.ResourceGroupName) -verbose -ErrorAction $SecondErrorAction
            if ((Get-AzResourceGroup -Name $rg.ResourceGroupName -verbose -ErrorAction SilentlyContinue) -ne $null) {
                Write-Host "=================================================================="
                Write-Host " Failed to delete: $($rg.ResourceGroupName) "
                Write-Host "=================================================================="
            }
        }
        else {
            Write-Host "ResourceGroup Not found (delete success)"
        }
    }
    else {
        # Write to the log that we skipped an RG due to the tag
        Write-Host "`nSkipping $($rg.ResourceGroupName) due to bypass tag...`n"
    }
}
