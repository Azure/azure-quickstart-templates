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

if ($MName){

	$ucfg = [Xml] (Get-Content "$safekitmod/$MName/conf/userconfig.xml")
	$ucfg.safe.service.farm.lan.name="default"


	$ucfg.Save("$safekitmod/$MName/conf/userconfig.xml")
	Log "$ucfg.OuterXml"
	

	$res = & $safekitcmd -H "*" -E $MName
	Log "$MName => $res"
	
	& $safekitcmd -H "*" start -m $MName
}

Log "end of script"


