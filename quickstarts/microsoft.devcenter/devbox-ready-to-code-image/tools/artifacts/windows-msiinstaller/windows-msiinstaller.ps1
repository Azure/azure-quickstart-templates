param(
    [Parameter(Mandatory=$true)]
    [string]$url
)

try {
    $output = "$PSScriptRoot\file.msi"
    
    Write-Host "Downloading $url..."
    Invoke-WebRequest $url -OutFile $output
    Write-Host "Download complete."

    Write-Host "Installing $output..."
    Start-Process msiexec -ArgumentList "/i $output /qn" -Wait -NoNewWindow
    Write-Host "Installation complete."

    Remove-Item $output
} catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
