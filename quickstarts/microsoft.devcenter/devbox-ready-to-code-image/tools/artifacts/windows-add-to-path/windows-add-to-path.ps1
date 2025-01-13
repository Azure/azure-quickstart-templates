param(
    [Parameter(Mandatory = $true)]
    [string]$newPath
)

try {
    Write-Host "Adding '$newPath' to system's Path environment variable"
    if ($newPath.Contains(";")) {
        Write-Host "WARNING: Cannot add path that contains ';' (semicolon) to system's Path environment variable"
        Write-Host "Not making any changes"
        exit 0
    }
    
    $path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $pathPieces = $path -split ";"
    if ($newPath -in $pathPieces) {
        Write-Host "Path already contains '$newPath'. Not making any changes."
    }
    else {
        $modifiedPath = $path + ";" + $newPath
        [Environment]::SetEnvironmentVariable("Path", $modifiedPath, 'Machine')
        Write-Host "'$newPath' added to system's Path environment variable"
    }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
