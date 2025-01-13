[CmdletBinding()]
param(
    [string] $WorkLoads,
    [String] $Sku,
    [String] $VSBootstrapperURL,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [String] $InstallationDirectory,
    [bool] $SkipNgenAfterInstall = $false
)

function Configure-WorkLoads {
    [CmdletBinding()]
    param(
        [string] $WorkLoads
    )

    switch ($WorkLoads) {
        'all' {
            $WorkLoads = '--all --includeRecommended --includeOptional'
        }

        'minimal' {
            $WorkLoads = '--add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NativeCrossPlat --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.VisualStudioExtension --includeRecommended --includeOptional'
        }

        'reduced' {
            $WorkLoads = '--add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NativeCrossPlat --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.VisualStudioExtension --add Microsoft.VisualStudio.Workload.Webcrossplat --includeRecommended --includeOptional'
        }

        'coreeditor' {
            $WorkLoads = '--add Microsoft.VisualStudio.Workload.CoreEditor'
        }
        default {
            $WorkLoads = $WorkLoads
        }
    }
    
    return $WorkLoads
}

$ErrorActionPreference = 'Stop'

function Run-WindowedApplication {
    param(
        [Parameter(Position = 0)][String]$command,
        [int[]]$AllowableExitStatuses = @(0),
        [int[]]$RetryableExitStatuses = @(),
        [Parameter(ValueFromRemainingArguments = $true)][String[]]$arguments
    )

    if (!$AllowableExitStatuses.Contains(0)) {
        $AllowableExitStatuses += 0
    }

    $maxRetries = 10
    $retry = 0
    while ($retry -le $maxRetries) {
        $outLog = [System.Guid]::NewGuid().ToString("N")
        $errLog = [System.Guid]::NewGuid().ToString("N")

        $startArgs = @{
            FilePath               = $command
            PassThru               = $true
            NoNewWindow            = $true
            Wait                   = $true
            RedirectStandardOutput = $outLog
            RedirectStandardError  = $errLog
        }

        if ($arguments) {
            $startArgs["ArgumentList"] = $arguments
        }

        $proc = Start-Process @startArgs

        if (Test-Path $outLog) {
            Get-Content $outLog | Out-Host
            Remove-Item $outLog -ErrorAction SilentlyContinue
        }

        if (Test-Path $errLog) {
            Get-Content $errLog | Out-Host
            Remove-Item $errLog -ErrorAction SilentlyContinue
        }

        if ($RetryableExitStatuses.Contains($proc.ExitCode)) {
            Write-Host "Retry-able exit code spotted: $($proc.ExitCode)"
            Start-Sleep -Seconds 10

            $retry += 1
            Write-Host "Retry $retry/$maxRetries"

            continue
        }

        if (!$AllowableExitStatuses.Contains($proc.ExitCode)) {
            $errorlogs = Get-ChildItem -Path $env:TEMP | Where-Object { $_.Name -like "*dd_setup*" -and $_.Name -like "*_errors*" }
            $bootstrapperErrorLogs = Get-ChildItem -Path $env:TEMP | Where-Object { $_.Name -like "*dd_boot*" }

            foreach ($errorlog in $errorlogs) { Get-Content -Path $errorlog.FullName | Write-Output }
            
            foreach ($bootstrapperErrorLog in $bootstrapperErrorLogs) { Get-Content -Path $bootstrapperErrorLog.FullName | Write-Output }
            throw "Commmand exit code: $($proc.ExitCode) - $command $arguments"
        }

        return
    }
}

$randomBootStrapperName = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
    
$vsSetupPath = "$env:Temp\$randomBootStrapperName.exe"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile $vsSetupPath

Write-Host "downloading $sku bootstrapper complete"

Write-Host "Configuring workloads"
$WorkLoads = Configure-WorkLoads -WorkLoads $WorkLoads
Write-Host $WorkLoads


if ($WorkLoads -eq "") {
    $Arguments = ('--quiet', '--norestart', '--wait' )
}
else {
    $Arguments = ($WorkLoads, '--quiet', '--norestart', '--wait' )
}

if (![System.String]::IsNullOrWhiteSpace($InstallationDirectory)) {
    Write-Host "Installing To: $InstallationDirectory"

    $Arguments += "--installPath ""$InstallationDirectory"""
}

Run-WindowedApplication -AllowableExitStatuses @(0, 3010) -RetryableExitStatuses 1618 $vsSetupPath $Arguments

$item = Get-ChildItem 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "Visual Studio 20*" -and $_.Attributes -like '*Archive*' }
if ($null -ne $item) {
    Copy-Item $item.FullName -Destination 'C:\Users\Public\Desktop' -Force -ErrorAction SilentlyContinue
}

if (!$SkipNgenAfterInstall) {
    # run ngen on the installed assemblies
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    @('Framework', 'Framework64') | ForEach-Object {
        try {
            $outFile = Join-Path $env:TEMP "ngen-$timestamp-$_.log"
            $errFile = Join-Path $env:TEMP "ngen-$timestamp-$_.err"

            $command = "C:\Windows\Microsoft.NET\$_\v4.0.30319\ngen.exe"
            $options = $('eqi')
            $cmdLine = "$command $($options -join ' ')"
            
            Write-Host "Running $cmdLine"
            Start-Process -FilePath $command -ArgumentList $options -Wait -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile
            Write-Host "Running $cmdLine completed"

            if (0 -ne $LASTEXITCODE) {
                Write-Host "Running $cmdLine completed with exit code $LASTEXITCODE"
            }
        }
        catch {
            # ignore - some errors are expected
            Write-Host "Running $cmdLine completed with error"
        }
    }
}
