param
(
    [String] $DBDataLUNS = "0,1,2",	
    [String] $DBLogLUNS = "3",
    [string] $DBDataDrive = "S:",
    [string] $DBLogDrive = "L:",
	[string] $DBDataName = "dbdata",
    [string] $DBLogName = "dblog"
)

$ErrorActionPreference = "Stop";

function Log
{
	param
	(
		[string] $message
	)
	$message = (Get-Date).ToString() + ": " + $message;
	Write-Host $message;
	if (-not (Test-Path ("c:" + [char]92 + "sapcd")))
	{
		$nul = mkdir ("c:" + [char]92 + "sapcd");
	}
	$message | Out-File -Append -FilePath ("c:" + [char]92 + "sapcd" + [char]92 + "log.txt");
}

Log "noop"
