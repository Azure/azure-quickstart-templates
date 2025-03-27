param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Script
)
try {
    $scriptBlock = [Scriptblock]::Create($Script)
    Write-Host "windows-powershell-invokecommand.ps1 will execute the following script: $scriptBlock" 
    Invoke-Command -ScriptBlock $scriptBlock -Verbose
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}