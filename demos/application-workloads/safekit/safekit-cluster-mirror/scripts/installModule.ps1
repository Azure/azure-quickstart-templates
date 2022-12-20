param(
	[string]$safekitcmd,
	[string]$MName,
	[string]$modulepkg,
	[string]$modulecfgscript
)

if( $modulepkg ){
    $module = $modulepkg.Split(',') | Get-ChildItem
}
else{
    $module = [array] (Get-ChildItem "*.safe")
}

if($module.Length){ 
	$module[0] | %{
        if($_){
			if($MName -and ($($MName.Length) -gt 0)) {
				$modulename=$MName
			}else{
				$modulename = $($_.name.Replace(".safe",""))
			}
            
            & $safekitcmd module install -m $modulename $_.fullname
			if($modulecfgscript -and (Test-Path  "./$modulecfgscript")){
				& ./$modulecfgscript
			}
            & $safekitcmd -H "*" -E $modulename
        }
	}
} 
