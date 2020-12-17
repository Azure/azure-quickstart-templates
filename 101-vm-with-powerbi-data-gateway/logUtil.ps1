class TraceLog {
	[string]$logPath
	[string]$logName
	[string]$logFilePath

	TraceLog(
		[string]$logPath,
		[string]$logName
	) {
		$this.logFilePath = Join-Path $logPath $logName
		if (! (Test-Path($this.logFilePath))) {
			New-Item -path $logPath -type directory -Force
		}
		$now = $this.Now()
		"${now} Create '$logName' `n" | Out-File $this.logFilePath
	}

	[string]LogFullPath() {
		return $this.logFilePath
	}

	[string] Now() {
		return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
	}

	[void] Log([string] $msg) {
		$now = $this.Now()
		try {
			"${now} $msg`n" | Out-File $this.logFilePath -Append
		}
		catch {
			#ignore any exception during trace
		}
	}
}

function Invoke-Process([string] $process, [string] $arguments, [TraceLog] $trace) {
	$errorFile = "$env:tmp\tmp$pid.err"
	$outFile = "$env:tmp\tmp$pid.out"
	"" | Out-File $outFile
	"" | Out-File $errorFile	

	$errVariable = ""
	$result = @{}

	if ([string]::IsNullOrEmpty($arguments)) {
		$proc = Start-Process $process -Wait -Passthru -NoNewWindow -RedirectStandardError $errorFile -RedirectStandardOutput $outFile -ErrorVariable errVariable
	}
	else {
		$proc = Start-Process $process -ArgumentList $arguments -Wait -Passthru -NoNewWindow -RedirectStandardError $errorFile -RedirectStandardOutput $outFile -ErrorVariable errVariable
	}
	
	$errContent = [string] (Get-Content -Path $errorFile -Delimiter "!!!DoesNotExist!!!")
	$outContent = [string] (Get-Content -Path $outFile -Delimiter "!!!DoesNotExist!!!")

	Remove-Item $errorFile
	Remove-Item $outFile
	
	if($proc.ExitCode -ne 0 -or $errVariable -ne "") {		
		$progressMsg = "Failed to run process: exitCode=$($proc.ExitCode), errVariable=$errVariable, errContent=$errContent, outContent=$outContent."
		Write-Error($progressMsg)
		if ($null -ne $trace) {
			$trace.Log($progressMsg)
		}
	}
	
	if ($null -ne $trace) {
		$trace.Log("Run-Process: ExitCode=$($proc.ExitCode), output=$outContent")
	}

	$result.add('Error', $errVariable)
	$result.add('ErrorDetail', $errContent)	
	$result.add('Output', $outContent)
	$result.add('ExitCode', $proc.ExitCode)
	return $result
}

function Install-Silent([string] $msiPath, [TraceLog] $trace) {
	if ($null -ne $trace) {
		if ([string]::IsNullOrEmpty($msiPath)) {
			$trace.Log("'$msiPath' path is not specified")
		}

		if (!(Test-Path -Path $msiPath)) {
			$trace.Log("Invalid msi path: '$msiPath'")
		}
		$trace.Log("Start '$msiPath' installation")
	}
	Run-Process "msiexec.exe" "/i '$msiPath' /quiet /norestart"		
}

function IsInstalled([string] $appName, [TraceLog] $trace) {
	# Use Get-CimInstance as exists on both PowerShell v5 & v7
	$installed = $null -ne (Get-CimInstance -Query "SELECT * FROM Win32_Product Where Name Like ""$appName""")
	if ($null -ne $trace) {
		$trace.Log("'$appName' installed = '$installed'")
	}
	return $installed
}