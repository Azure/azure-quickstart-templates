param(
        [string] $publicipfmt,
        [string] $privateiplist,
        [string] $vmlist,
		[string] $lblist,
		[string] $Passwd
)

$safekitcmd=$env:SAFEKITCMD
$safevar=$env:SAFEVAR
$safewebconf=$env:SAFEWEBCONF
$logdir=$pwd

function Log {
        param(
                [string] $m
        )

        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        Add-Content "$logdir/installsk.log" "$stamp [configCluster.ps1] $m"
}

Log $vmlist
Log $publicipfmt
Log $privateiplist
Log $lblist

if ($vmlist){
    $vmargs=@()
	$lbargs=@()
    $privateipargs=@()
	$targets=@()
	
	"[" | Out-File -Encoding ASCII -FilePath "$safewebconf/ipnames.json"
	"[" | Out-File -Encoding ASCII -FilePath "$safewebconf/ipv4.json"

	
	$vmargs += ([regex]::Replace($vmlist,'[\[\]]','') -split ',')
	$privateipargs += ([regex]::Replace($privateiplist,'[\[\]]','') -split ',')
	if($lblist){
		$lbargs += ($lblist -split ',')
	}
    Log "configuring cluster.xml and certificates input files"

	$str = "<cluster><lans>"
	if($publicipfmt){
		$str +="<lan name='External' console='on' command='off' framework='off'>"
	
		for ($i=0; $i -lt $vmargs.Length; $i++){
			$dnsname=$($publicipfmt).Replace('%VM%',$($vmargs[$i])).ToLower()
			$str += "<node name='$($vmargs[$i])' addr='$dnsname'/>"
			"`"$dnsname`"," | Out-File -Append -Encoding ASCII -FilePath "$safewebconf/ipnames.json"
		}
		
		$str += "</lan>"
	}
	
	for($i=0; $i -lt $lbargs.Length; $i++){
		$dnsname = $($lbargs[$i])
		if($dnsname.Length){
			"`"$dnsname`"," | Out-File -Append -Encoding ASCII -FilePath "$safewebconf/ipnames.json"
		}
	}
	"null]" | Out-File -Append -Encoding ASCII -FilePath "$safewebconf/ipnames.json"
    
	
	$str +="<lan name='default' console='on' command='on' framework='on' >"
	for ($i=0; $i -lt $vmargs.Length; $i++){
			$str += "<node name='$($vmargs[$i])' addr='$($privateipargs[$i])'/>"
			"`"$($privateipargs[$i])`"," | Out-File -Append -Encoding ASCII -FilePath "$safewebconf/ipv4.json"
			$targets += $($privateipargs[$i])
	}
	"null]" | Out-File -Append -Encoding ASCII -FilePath "$safewebconf/ipv4.json"
	
    $str += "</lan></lans></cluster>"
    $str | Out-File -Encoding utf8 $safevar\cluster\cluster.xml
	& $safekitcmd cluster config 2>&1
    $res= & $safekitcmd -H "[http],*" -G 2>&1
    Log "result = $res"
	if( Test-Path "./uploadcerts.ps1") {
		& ./uploadcerts.ps1 -skbase "$env:SAFEBASE" -targets $targets -userpwd "CA_admin:$Passwd"
	}
}

Log "end of script"



