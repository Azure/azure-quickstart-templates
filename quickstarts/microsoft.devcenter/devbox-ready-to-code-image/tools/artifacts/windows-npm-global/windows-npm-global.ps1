param(
    [Parameter(Mandatory=$true)]
    [string]$packages,
    [Parameter(Mandatory=$false)]
    [bool]$addToPath=$true
)

try {
    $packageArray = $packages.split(",")
    $npmPrefix = "C:\npm"
    npm config set prefix $npmPrefix

    for ($i = 0; $i -lt $packageArray.count; $i++) {
        $package = $packageArray[$i].trim()

        Write-Host "Installing $package globally"
        npm install -g $package
        Write-Host "Installation complete"
    }

    if ($addToPath) {
        Write-Host "Adding npm prefix to PATH"
	[Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$npmPrefix", "Machine")
        Write-Host "npm prefix added to PATH"
    }
} catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
