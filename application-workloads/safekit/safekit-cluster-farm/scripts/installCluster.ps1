param(
	[string] $publicipfmt,
	[string] $privateiplist,
    [string] $vmlist,
	[string] $lblist,
	[string] $Passwd
)

$targetDir = "."

function Log {
	param(
		[string] $m
	)

	$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
	Add-Content ./installsk.log "$stamp [installCluster.ps1] $m" 
}

Log $vmlist 
Log $publicipfmt
Log $privateiplist

$env:SAFEBASE="/safekit"	
$env:SAFEKITCMD="/safekit/safekit.exe"
$env:SAFEVAR="/safekit/var"
$env:SAFEWEBCONF="/safekit/web/conf"
	
& ./configCluster.ps1 -vmlist $vmlist -publicipfmt $publicipfmt -privateiplist $privateiplist -lblist $lblist -Passwd $Passwd

Log "end of script"


