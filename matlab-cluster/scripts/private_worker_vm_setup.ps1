# mjs & worker vm setup script - run on mjs and worker VMs within a private cluster

# Calling this as mdcssetup.ps1, nothing will happen
# Calling this as "mdcssetup.ps1 shim", a subprocess will be launched to run the setup process, current process will exit immediately
# Calling this as "mdcssetup.ps1 run", setup process will be executed

function trace() {
    param(
    [Parameter(
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true)
    ]
    [String[]]$log
    )

    filter timestamp {"$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss.fff'): $_"}
    if((Test-Path variable:logfile) -eq $false)
    {
        $datetimestr = (Get-Date).ToString('yyyy-MM-dd-HH-mm-ss')
        $script:logfile = "$env:windir\Temp\MDCSLog-$datetimestr.log"
    }
    $log | timestamp | Out-File -Confirm:$false -FilePath $script:logfile -Append
}

function GenPass($textToHash) {
  $chars = @([int][char]'a'..[int][char]'z') + @([int][char]'A'..[int][char]'Z') + @([int][char]'0'..[int][char]'9')
  $hasher = new-object System.Security.Cryptography.SHA256Managed
  $toHash = [System.Text.Encoding]::UTF8.GetBytes($textToHash)
  $hashByteArray = $hasher.ComputeHash($toHash)
  foreach($byte in $hashByteArray)  {
    $res += [char]$chars[[int]$byte%$chars.length]
  }
  return "!" + $res.substring(0,12) + "$";
}

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

function main($p) {

whoami | trace

# Script Extension to install Matlab
# Step 1. Download MDCS.zip & installation text file
#$webclient = New-Object System.Net.webclient

#$mdcs_source = "https://markmatlab.blob.core.windows.net/mdcs-download/MDCS.zip?sv=2014-02-14&st=2015-10-03T05%3A45%3A00Z&se=2016-11-03T06%3A45%3A00Z&sr=b&sp=r&sig=5QyGBf%2Bo9BUXwft7YN5nrcwomzdEmod84iyFLj4OPvE%3D"
#$installfile_source = "https://raw.githubusercontent.com/YidingZhou/azure-quickstart-templates/matlab/matlab/installer_input.txt"

#$destination = $env:temp

#$zipfile = $destination + "\mdcs.zip"
#$installconfig = $destination + "\installer_input.txt"

#echo "downloading config" | trace
#$webclient.downloadfile($installfile_source, $installconfig)
#echo "downloading mdcs zip" | trace
#$webclient.downloadfile($mdcs_source, $zipfile)

# Step 2. Unzip MDCS to %TEMP%
#echo "extracing" | trace
#$mdcs_folder = $destination + "\mdcs\"
#[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
#[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $mdcs_folder)

# Step 3. Run setup
#echo "installing" | trace
#start-process -FilePath $mdcs_folder\MDCS\setup.exe -ArgumentList "-inputfile",$installconfig -nonewwindow -wait

# Step 4. Update mdce_def for hosted license and hostname suffix
$matlabroot = FindMatlabRoot
$mdcsdir = $matlabroot + "\toolbox\distcomp\bin"

echo "config mdce_def" | trace
$configfile = $mdcsdir + "\mdce_def.bat"
# internal DNS name
$dnssuffix = (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $env:COMPUTERNAME | ? {$_.IPEnabled} | ?{$_.DNSDomain -ne $null}).DNSDomain

# the coupled configuration doesn't assign public ip to master or worker, everything goes through private ip
$masterfqdn = "master.$dnssuffix"
$hostfqdn = $env:COMPUTERNAME + '.' + $dnssuffix

# Make sure the private DNS name of the master can be resolved on all nodes
while(($t -lt 360) -and ($True -ne (Resolve-Dnsname $masterfqdn))) {
  echo "keep contacting master" | trace
  Start-Sleep 10
  ipconfig /flushdns
  $t++
};

(Get-Content $configfile) | Foreach-Object {$_ -replace '^REM set HOSTNAME=.+$', ('set HOSTNAME=' + $env:COMPUTERNAME)} | Set-Content ($configfile)
(Get-Content $configfile) | Foreach-Object {$_ -replace '^set USE_MATHWORKS_HOSTED_LICENSE_MANAGER=.+$', ("set USE_MATHWORKS_HOSTED_LICENSE_MANAGER=true")} | Set-Content ($configfile)
(Get-Content $configfile) | Foreach-Object {$_ -replace '^set MDCEUSER=$', ('set MDCEUSER=' + $env:COMPUTERNAME + '\' + $script:username)} | Set-Content ($configfile)
(Get-Content $configfile) | Foreach-Object {$_ -replace '^set MDCEPASS=$', ('set MDCEPASS=^^' + $script:password)} | Set-Content ($configfile)

# Step 5. Install & Start MDCE service
echo "install mdce service" | trace
Set-Location $mdcsdir
.\mdce.bat install 2>&1 | trace
.\mdce.bat start -clean -loglevel 6 2>&1 | trace

# Step 6. Add firewall exceptions for matlab, enable remote SC management
echo "config firewall" | trace
Get-NetFirewallRule | ?{$_.Name -like "RemoteSvcAdmin*"} | Enable-NetFirewallRule
New-NetFirewallRule -Name "mdcs" -DisplayName "mdcs" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 27000-28000
New-NetFirewallRule -Name "mdcs2" -DisplayName "mdcs2" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 14351-14448
New-NetFirewallRule -Name "mdcs_out" -DisplayName "mdcs_out" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 27000-28000
New-NetFirewallRule -Name "mdcs2_out" -DisplayName "mdcs2_out" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 14351-14448

# for now - just disable the firewall
netsh advfirewall set allprofiles state off

echo ("args are $p nb of args is " + $p.Count) | trace

# Step 7. Install MJS - master only. Step 1-6 can be done via a custom image.
if($p.Count -gt 4) { # for master only
  # - Start MJS job manager
  echo "starting job manager"  | trace
  .\startjobmanager.bat -name mymjs -v 2>&1 | trace
}

# Step 8. open PING
echo "opening PING" | trace
Get-NetFirewallRule | ?{$_.Name -like "FPS-ICMP*"} | Enable-NetFirewallRule

# Step 9. Block until master can be contacted, if master can be ping-ed, mjs has been setup on master
echo "contacting master" | trace
# Block until can ping, max try 10*360 seconds. If this machine IS master, it'll pass directly
while(($t -lt 360) -and ($True -ne ( Test-Connection -count 1 -computer $master -quiet ))) {
  echo "keep contacting master" | trace
  Start-Sleep 10
  $t++
};

# Step 10. Launch worker. Both master and worker can share this step
$total = $p[$p.length-1] # the last argument is the # of workers
if($total -eq -1) { # -1 means auto, # of workers == # of cores
  $total = (Get-WmiObject -class win32_processor -Property "numberOfCores").NumberOfCores
}
echo "start worker (total - $total)" | trace
for($i=0;$i -lt $total;$i++) {
  $workername = "WORKER_" + $env:COMPUTERNAME + "_" + $i + "_" + $total
  echo "add worker $workername" | trace
  .\startworker.bat -jobmanagerhost "master" -jobmanager mymjs -name $workername -v 2>&1 | trace
}
echo "all done. exit." | trace
}

function bgrun($p) {
  if([string]::IsNullOrEmpty($p)) { # this check could use some improvement TODO
    $arglist = "-ExecutionPolicy Unrestricted -file " + $MyInvocation.ScriptName + " run"
  } else {
    $arglist = "-ExecutionPolicy Unrestricted -file " + $MyInvocation.ScriptName + " run " + [string]::join(" ", $p)
  }
  echo "creating action arglist is $arglist" | trace

  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arglist

  $newuser = $script:username
  $password = $script:password #GenPass((Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $env:COMPUTERNAME | ? {$_.IPEnabled}).DNSDomain)

  NET USER $newuser $password /ADD
  NET LOCALGROUP "Administrators" $newuser /ADD

  $username = $env:COMPUTERNAME + "\" + $newuser

  echo "register task with $username - password $password " | trace
  Register-ScheduledTask -TaskName "mdcssetup" -Action $action -User $username -Password $password *>>$script:logfile
  if(-not $?) {
    trace 'Failed to register task.'
    throw
  }

  echo "run task" | trace
  Start-ScheduledTask -TaskName "mdcssetup" *>>$script:logfile
  if(-not $?) {
    trace 'Failed to schedule task.'
    throw
  }
}

# bootstrap
$MyInvocation | Out-String | trace

$script:username = "mdcsuser"
$script:password = GenPass((Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $env:COMPUTERNAME | ? {$_.IPEnabled}).DNSDomain)

foreach($arg in $args) {
  if(0 -eq $arg.ToLower().CompareTo("shim")) {
    echo "launch bgrun with $($args[1])" | trace
    if($args.Count -gt 1) {
      bgrun($args[1..($args.length-1)])
    } else {
      bgrun("")
    }
    exit
  } elseif (0 -eq $arg.ToLower().CompareTo("run")) {
    echo "calling to main with $args" | trace
    main($args)
    exit
  }
}
