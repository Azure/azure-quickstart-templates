function Find-VarsFromWriteHostOutput {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]
        $InputObject
    ) 
    $vars = New-Object -type "Hashtable"

    $InputObject | ForEach-Object {
        if ($_ -match "##vso\[task.setvariable variable=([a-zA-Z.]+)\](.+)") {
            $var = $Matches[1]
            $value = $Matches[2]

            # Convert variable name from xxx.yyy.zzz to XXX_YYY_ZZZ
            $var = $var.ToUpperInvariant().Replace(".", "_")
            $vars[$var] = $value
            Write-Host "$var = '$value'"
        }
    }

    return $vars
}

function Assert-IsTrue([bool] $condition, $message) {
    if (!$condition) {
        Write-Error "Assertion failed: $message"
    }
}

function Assert-NotEmptyOrNull([string] $string, $message) {
    if (!($string -is [string]) -or $string -eq "") {
        Write-Error "Assertion failed: String should not be empty or null: $message"
    }
}   

function Get-SampleNameFromFolderPath([string] $SampleFolder) {
    $root = Get-SampleRootPath $SampleFolder
    return Get-RelativePath $root $SampleFolder
}

function Get-SampleRootPath([string] $SampleFolder = ".") {
    $folder = Resolve-Path $SampleFolder

    while (Test-Path $folder) {
        $contributionGuidePath = Join-Path $folder "1-CONTRIBUTION-GUIDE"
        if (Test-Path ($contributionGuidePath)) {
            return $folder
        }
        else {
            $folder = Split-Path $folder -Parent
        }
    }

    Write-Error "Couldn't find sample name for path $SampleFolder"
    Return $null
}

function Get-RelativePath([string] $base, [string] $destination) {
    return [System.IO.Path]::GetRelativePath($base, $destination)
}

function Remove-GeneratorMetadata(
    [string] $jsonContent
) {
    # Remove the top-level metadata the generator information is there, including the bicep version, and this would
    # affect file comparisons where only the bicep version differs
    $json = ConvertFrom-Json $jsonContent
    if ($json) {
        $json.PSObject.properties.remove('metadata')
    }
    else {
        Write-Error "Template is empty"
    }
    return ConvertTo-JSON $json -Depth 100
}

function Convert-StringToLines(
    [string] $content
) {
    <#
        .SYNOPSIS
        Converts a multi-line string to an array of strings, each element corresponding to a line
    #>
    
    return @($content -split '\r\n|\n|\r')
}

function Convert-LinesToString(
    [string[]] $lines
) {
    <#
        .SYNOPSIS
        Converts an array of strings, each element corresponding to a line, into a multi-line string
    #>
    
    return $lines -join [System.Environment]::NewLine
}