﻿param(
[Parameter(Mandatory=$true)]
[PSObject]
$TemplateObject
)

<#
Skipping this test for now... there are a few issues:
- this only applies to Stock Images, or images that do not use a "plan" object, but there are some images (e.g. MSDN) that don't have a "plan" object and do not allow for "latest"
- Expand-AzTemplate does not account for parameters when doing the eval

$vms = $TemplateObject | Find-JsonContent -Key type -Value Microsoft.Compute/virtualMachines


foreach ($vm in $vms) {
    $storageProfile = $vm.properties.storageProfile

    if ($storageProfile -is [string]) { # If the storageProfile was a string,
        # set storageProfile to the resolved expression
        $storageProfile = Expand-AzTemplate -Expression $storageProfile -InputObject $TemplateObject
    }

    if (-not $storageProfile) { # If the storageProfile didn't resolve
        Write-Error "Could not resolve storage profile" -TargetObject $vm # write an error
        continue # and move onto the next
    }

    $imageReference = $storageProfile.imageReference

    if ($imageReference -is [string]) { # If the image reference was a string
        # set it to the resolved expression
        $imageReference = Expand-AzTemplate -Expression $imageReference -InputObject $TemplateObject
    }

    if (-not $imageReference) { # If no image reference was found
        Write-Error "Could not resolve image reference" -TargetObject $storageProfile # write an error
        continue # and move onto the next
    }

    $imageVersion = $imageReference.version

    if ($imageVersion -ne 'latest') { # If the image version isn't latest
        # try resolving it
        $resolvedImageVersion = Expand-AzTemplate -Expression $imageVersion -InputObject $TemplateObject
        if ($resolvedImageVersion -ne 'latest') { # If it still wasn't latest
            Write-Error "VM Image versions should be Latest, not $($resolvedImageVersion)" -TargetObject $vm # write an error.
        }
    }
}

#>