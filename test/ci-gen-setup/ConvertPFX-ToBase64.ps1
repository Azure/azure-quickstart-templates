
param(
    [string] [Parameter(mandatory = $true)] $pfxFile
)

$fileContent = get-content "$pfxFile" -AsByteStream 
[System.Convert]::ToBase64String($fileContent) | Set-Content -Encoding ascii "$pfxFile.txt"
