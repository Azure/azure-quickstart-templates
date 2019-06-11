[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)][string]$source = "https://api.github.com/repos/Azure/azure-quickstart-templates/contents/test/template-tests",
    [Parameter(Mandatory = $true)][string]$dest,
    [Parameter(Mandatory = $false)][string]$user,
    [Parameter(Mandatory = $false)][string]$pass

)

if($pass -and $user){
    $pair = "$($user):$($pass)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = "Basic $encodedCreds"
    $Headers = @{
        Authorization = $basicAuthValue
    }
}
function DownloadFiles([string]$sourceUri, [string]$destFolder) {

    Write-Verbose "Getting contents from $sourceUri"
    $folderContents = Invoke-WebRequest $sourceUri -UseBasicParsing -Headers $Headers | Select-Object -ExpandProperty Content | ConvertFrom-Json

    foreach ($file in $folderContents) {
        if ($file.type -eq "dir") {
            Write-Verbose "Changing Directory to: $sourceUri/$($file.name)"
            if ( -Not ( Test-Path -Path "$destFolder/$($file.name)" ) ) {
                New-Item -ItemType directory -Path "$destFolder/$($file.name)"
            }
            DownloadFiles "$sourceUri/$($file.name)" "$destFolder/$($file.name)"
        }
        else {
            Write-Verbose "Downloading $($file.download_url)..."
            Write-Verbose "Outfile: $destFolder/$($file.name)"
            Invoke-WebRequest $file.download_url -UseBasicParsing -OutFile "$destFolder/$($file.name)"
        }
    }

}

DownloadFiles $source $dest

Get-ChildItem $destFolder
