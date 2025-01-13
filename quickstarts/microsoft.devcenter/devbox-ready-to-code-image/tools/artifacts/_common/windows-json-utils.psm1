<#
.DESCRIPTION
    Utilities for handling JSON files/content.
#>

function Get-JsonFromFile {
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $FilePath
    )

    try {
        $json = Get-Content $FilePath | ConvertFrom-Json
    }
    catch {
        Write-Host "Stripping comments from $FilePath and converting to JSON"
        $json = (Get-Content $FilePath -Raw) -replace '(?<=[^/])//.*' | ConvertFrom-Json
    }

    return $json
}
