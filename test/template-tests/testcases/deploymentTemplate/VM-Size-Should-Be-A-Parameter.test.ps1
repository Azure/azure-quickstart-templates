param(
[Parameter(Mandatory=$true)]
[PSObject]
$TemplateObject
)

$vms = $TemplateObject | Find-JsonContent -Key type -Value Microsoft.Compute/virtualMachines


foreach ($vm in $vms) {
    if ($vm.plan) {
        Write-Verbose "Skipping $($vm.Name) because it has a plan"
        continue
    }
    $hardwareProfile = $vm.properties.hardwareProfile

    if ($hardwareProfile -is [string]) { # If the hardwareProfile was a string,
        # set hardwareProfile to the resolved expression
        $hardwareProfile = Expand-AzureRMTemplate -Expression $hardwareProfile -InputObject $TemplateObject
    }

    if (-not $hardwareProfile) { # If the hardwareProfile didn't resolve
        Write-Error "Could not resolve hardware profile" -TargetObject $vm # write an error
        continue # and move onto the next
    }


    $vmSize = $hardwareProfile.vmSize

    if ($vmSize -notmatch '\[parameters\(') {
        if ($vmSize -match '\[variables\(') { 
            $resolvedVmSize = Expand-AzureRMTemplate -Expression $vmSize -InputObject $TemplateObject
            if ($resolvedVmSize -notmatch '\[parameters\(') {
                Write-Error "VM Size must be a parameter" -TargetObject $vm
            }
        } else {
            Write-Error "VM Size must be a parameter" -TargetObject $vm           
        }
    }
}