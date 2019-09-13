param(
[Parameter(Mandatory=$true)]
[PSObject]
$TemplateObject
)

# Find all references to an adminUserName
$adminUserNameRefs = $TemplateObject | 
    Find-JsonContent -Key adminUsername  -Value * -Like |
    Where-Object { -not $_.ParentObject[0].'$schema' } # unless they're on a top-level property.
    

foreach ($ref in $adminUserNameRefs) { # Walk over each one
    $trimmedUserName = "$($ref.adminUserName)".Trim()
    if ($trimmedUserName -notmatch '\[[^\]]+\]') { # If they aren't expressions
        Write-Error -TargetObject $ref -Message "AdminUsername is not an expression" # write an error
        continue # and move onto the next
    }
}

  

 
