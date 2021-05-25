param(
	[string] $safekitcmd,
	[string] $safekitmod,
	[string] $MName
)



function Log {
	param(
		[string] $m
	)

	$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
	Add-Content ./installsk.log "$stamp $m" 
}

Log $safekitcmd 
Log $MName

$repdir = "$env:systemdrive/replicated"

if ($MName){

	$ucfg = [Xml] (Get-Content "$safekitmod/$MName/conf/userconfig.xml")
	$ucfg.safe.service.heart.heartbeat.name="default"
	[xml]$rfsconf="<rfs><replicated dir='$repdir'/></rfs>"
	$ucfg.safe.service.AppendChild($ucfg.ImportNode($rfsconf.rfs,$true))

	$ucfg.Save("$safekitmod/$MName/conf/userconfig.xml")
	Log "$ucfg.OuterXml"
	

	
	$res = & $safekitcmd -H "*" -E $MName
	Log "$MName => $res"
	& $safekitcmd prim -m $MName
	& $safekitcmd -H "VM2" start -m $MName
}

Log "end of script"


