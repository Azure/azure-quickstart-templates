# start/stop mdce services

function FindMatlabRoot() {
    $computername = $env:computername
    $MatlabKey="SOFTWARE\\MathWorks\\MATLAB"
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername) 
    $regkey=$reg.OpenSubKey($MatlabKey) 
    $subkeys=$regkey.GetSubKeyNames() 
    $matlabroot = ""
    foreach($key in $subkeys){
        $thisKey=$MatlabKey + "\\" + $key 
        $thisSubKey=$reg.OpenSubKey($thisKey)
        $thisroot = $thisSubKey.GetValue("MATLABROOT")
        if($matlabroot -lt $thisroot) {
            $matlabroot = $thisroot
        }
    } 
    return $matlabroot
}

function get_mdce_path() {
  $matlabroot = FindMatlabRoot
  $matlabroot = $matlabroot -replace ' ', '` ' # dealing with 'Program Files'
  $mdceutil = $matlabroot + "\toolbox\distcomp\bin\mdce.bat" 
  return $mdceutil
}

function mdce_start($p) {
    
  # Before starting service, make sure master is reachable
  echo "contacting master" *>> "$env:windir\Temp\MDCSLog.log"
  # Block until can ping, max try 10*360 seconds. If this machine IS master, it'll pass directly
  while(($t -lt 360) -and ($True -ne ( Test-Connection -count 1 -computer $master -quiet ))) {
    echo "keep contacting master" *>> "$env:windir\Temp\MDCSLog.log"
    Start-Sleep 10
    $t++
  };
  
  echo "start mdce services util start" *>> "$env:windir\Temp\MDCSLog.log"
  $cli = get_mdce_path
  echo "finding cli path $cli"
  $cli = $cli + " start"
  echo "invoking $cli" *>> "$env:windir\Temp\MDCSLog.log"
  Invoke-Expression $cli *>> "$env:windir\Temp\MDCSLog.log"
}

function mdce_stop($p) {
  echo "start mdce services util stop" *>> "$env:windir\Temp\MDCSLog.log"
  $cli = get_mdce_path
  echo "finding cli path $cli"
  $cli = $cli + " stop"
  echo "invoking $cli" *>> "$env:windir\Temp\MDCSLog.log"
  Invoke-Expression $cli *>> "$env:windir\Temp\MDCSLog.log"
}

function usage($p) {
  echo "tell me something..." *>> "$env:windir\Temp\MDCSLog.log"
}

function parse_param($p) {
  if($p.Count -eq 0) {
    usage
    exit
  }
  $command = $p[0]
  if($p.length -gt 1) {
    $command_args = $p[1..($p.length-1)]
  }
  switch ($p[0]) {
    "start" { mdce_start($command_args); break }
    "stop" { mdce_stop($command_args); break }
    default { usage; exit}
  }
}

# parse_param will parse the parameter and drive the workflow
parse_param($args)
