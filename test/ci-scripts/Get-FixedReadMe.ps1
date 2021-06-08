param(
    [string] $ReadmeContents,
    [string] $ExpectedMarkdown
)

Import-Module "$PSScriptRoot/Local.psm1" -force
$newLine = [System.Environment]::NewLine

function DoesLineLookLikeBadgeLinkOrButton([string] $line) {
    if ($line -match "!\[") {
        if ($line -match "\/badges\/") {
            return $true
        }
        if ($line -match "deploytoazure.svg|deploytoazuregov.svg|visualizebutton.svg") {
            return $true
        }
    }

    return $false
}

$mark = "YAYBADGESYAY"
$lines = Convert-StringToLines $readmeContents

for ($i = 0; $i -lt $lines.Count; $i++) {
    if (DoesLineLookLikeBadgeLinkOrButton $lines[$i]) {
        # Replace the line with the badge with a mark
        $lines[$i] = $mark
    }
}

$fixed = Convert-LinesToString $lines
if ($fixed -notlike "*$mark*") {
    # No badges found at all        
    throw "Unable to automatically fix README badges and buttons - no badges or buttons found"
}
else {
    # Remove whole area of badges with optional blank lines between with a single mark
    $fixed = $fixed -replace "$mark([`r`n]|$mark)+", "$mark"

    if ($fixed -match "(?ms)$mark.*$mark") {
        # There's more than one mark left, meaning the badges/buttons were not contiguous
        throw "Unable to automatically fix README badges and buttons - badges/buttons are not contiguous in the README"
    }

    # Replace the remaining mark with the expected markdown
    $fixed = $fixed -replace "[`r`n]*$mark[`r`n]*", "$newLine$newLine$($ExpectedMarkdown.Trim())$newLine$newLine"

    return $fixed
}
