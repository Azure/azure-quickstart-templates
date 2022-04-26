#clear windows proxy

$size = (Get-PartitionSupportedSize -DiskNumber 0 -PartitionNumber 1)
[System.Uint64]$currentsize = (Get-Partition -DiskNumber 0 -PartitionNumber 1).Size
[System.Uint64]$maxpartitionsize = ($size.SizeMax).ToString()

if ($($currentsize) -ge $($maxpartitionsize)) {
"Hard Drive already expanded"
}
Else
{
Resize-Partition -DiskNumber 0 -PartitionNumber 1 -Size $size.SizeMax
"Successfully Increased Partition Size"
}


function clear-proxy {
$value = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable
if ($value.ProxyEnable -eq 1) {
set-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -value 0 | Out-Null
write-host "Disable proxy if required"
Start-Process "C:\Program Files\Internet Explorer\iexplore.exe"
Start-Sleep -s 5
Get-Process iexplore | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force}
Else {}}

#fix gpu

function EnableDisabledGPU {
$getdisabled = Get-WmiObject win32_pnpentity | Where-Object {$_.name -like '*NVIDIA*' -or $_.name -like '3D Video Controller' -and $_.status -like 'Error'} | Select-Object -ExpandProperty PNPDeviceID
if ($getdisabled -ne $null) {"Enabling GPU"
$var = $getdisabled.Substring(0,21)
$arguement = "/r enable"+ ' ' + "*"+ "$var"+ "*"
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList $arguement
}
Else {"Device is enabled"
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList '/m /r'}
}



function installedGPUID {
#queries WMI to get DeviceID of the installed NVIDIA GPU
Try {(get-wmiobject -query "select DeviceID from Win32_PNPEntity Where (deviceid Like '%PCI\\VEN_10DE%') and (PNPClass = 'Display' or Name = '3D Video Controller')"  | Select-Object DeviceID -ExpandProperty DeviceID).substring(13,8)}
Catch {return $null}
}

function driverVersion {
#Queries WMI to request the driver version, and formats it to match that of a NVIDIA Driver version number (NNN.NN) 
Try {(Get-WmiObject Win32_PnPSignedDriver | where {$_.DeviceName -like "*nvidia*" -and $_.DeviceClass -like "Display"} | Select-Object -ExpandProperty DriverVersion).substring(7,6).replace('.','').Insert(3,'.')}
Catch {return $null}
}

function osVersion {
#Requests Windows OS Friendly Name
(Get-WmiObject -class Win32_OperatingSystem).Caption
}

function requiresReboot{
#Queries if system needs a reboot after driver installs
if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
 try { 
   $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
   $status = $util.DetermineIfRebootPending()
   if(($status -ne $null) -and $status.RebootPending){
     return $true
   }
 }catch{}
 
 return $false
}

function validDriver {
#checks an important nvidia driver folder to see if it exits
test-path -Path "C:\Program Files\NVIDIA Corporation\NVSMI"
}

Function webDriver { 
#checks the latest available graphics driver from nvidia.com
if (($gpu.supported -eq "No") -eq $true) {"Sorry, this GPU (" + $gpu.name + ") is not yet supported by this tool."
Exit
}
Elseif (($gpu.Supported -eq "UnOfficial") -eq $true) {
if ($url.GoogleGRID -eq $null) {$URL.GoogleGRID = Invoke-WebRequest -uri https://cloud.google.com/compute/docs/gpus/add-gpus#installing_grid_drivers_for_virtual_workstations -UseBasicParsing} Else {}
$($($URL.GoogleGRID).Links | Where-Object href -like *server2016_64bit_international.exe*).outerHTML.Split('/')[6].split('_')[0]
}
Else { 
$gpu.URL = "https://www.nvidia.com/Download/processFind.aspx?psid=" + $gpu.psid + "&pfid=" + $gpu.pfid + "&osid=" + $gpu.osid + "&lid=1&whql=1&lang=en-us&ctk=0"
$link = Invoke-WebRequest -Uri $gpu.URL -Method GET -UseBasicParsing
$link -match '<td class="gridItem">([^<]+?)</td>' | Out-Null
if (($matches[1] -like "*(*") -eq $true) {$matches[1].split('(')[1].split(')')[0]}
Else {$matches[1]}
}
}

function GPUCurrentMode {
#returns if the GPU is running in TCC or WDDM mode
$nvidiaarg = "-i 0 --query-gpu=driver_model.current --format=csv,noheader"
$nvidiasmi = "c:\program files\nvidia corporation\nvsmi\nvidia-smi" 
try {Invoke-Expression "& `"$nvidiasmi`" $nvidiaarg"}
catch {$null}
}

function queryOS {
#sets OS support
if (($system.OS_Version -like "*Windows 10*") -eq $true) {$gpu.OSID = '57' ; $system.OS_Supported = $false}
elseif (($system.OS_Version -like "*Windows 8.1*") -eq $true) {$gpu.OSID = "41"; $system.OS_Supported = $false}
elseif (($system.OS_Version -like "*Server 2016*") -eq $true) {$gpu.OSID = "74"; $system.OS_Supported = $true}
elseif (($system.OS_Version -like "*Server 2019*") -eq $true) {$gpu.OSID = "74"; $system.OS_Supported = $true}
Else {$system.OS_Supported = $false}
}

function webName {
#Gets the unknown GPU name from a csv based on a deviceID found in the installedgpuid function
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/parsec-cloud/Cloud-GPU-Updater/master/Additional%20Files/GPUID.csv", $($system.Path + "\GPUID.CSV")) 
Import-Csv "$($system.path)\GPUID.csv" -Delimiter ',' | Where-Object DeviceID -like *$($gpu.Device_ID)* | Select-Object -ExpandProperty GPUName
}

function queryGPU {
#sets details about current gpu
if($gpu.Device_ID -eq "DEV_13F2") {$gpu.Name = 'NVIDIA Tesla M60'; $gpu.PSID = '75'; $gpu.PFID = '783'; $gpu.NV_GRID = $true; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "Yes"} 
ElseIF($gpu.Device_ID -eq "DEV_118A") {$gpu.Name = 'NVIDIA GRID K520'; $gpu.PSID = '94'; $gpu.PFID = '704'; $gpu.NV_GRID = $true; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "Yes"} 
ElseIF($gpu.Device_ID -eq "DEV_1BB1") {$gpu.Name = 'NVIDIA Quadro P4000'; $gpu.PSID = '73'; $gpu.PFID = '840'; $gpu.NV_GRID = $false; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "Yes"} 
Elseif($gpu.Device_ID -eq "DEV_1BB0") {$gpu.Name = 'NVIDIA Quadro P5000'; $gpu.PSID = '73'; $gpu.PFID = '823'; $gpu.NV_GRID = $false; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "Yes"}
Elseif($gpu.Device_ID -eq "DEV_15F8") {$gpu.Name = 'NVIDIA Tesla P100'; $gpu.PSID = '103'; $gpu.PFID = '822'; $gpu.NV_GRID = $true; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "UnOfficial"}
Elseif($gpu.Device_ID -eq "DEV_1BB3") {$gpu.Name = 'NVIDIA Tesla P4'; $gpu.PSID = '103'; $gpu.PFID = '831'; $gpu.NV_GRID = $true; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "UnOfficial"}
Elseif($gpu.Device_ID -eq "DEV_1EB8") {$gpu.Name = 'NVIDIA Tesla T4'; $gpu.PSID = '110'; $gpu.PFID = '883'; $gpu.NV_GRID = $true; $gpu.Driver_Version = driverversion; $gpu.Web_Driver = webdriver; $gpu.Update_Available = ($gpu.Web_Driver -gt $gpu.Driver_Version); $gpu.Current_Mode = GPUCurrentMode; $gpu.Supported = "UnOfficial"}
Elseif($gpu.Device_ID -eq $null) {$gpu.Supported = "No"; $gpu.Name = "No Device Found"}
else{$gpu.Supported = "No"; $gpu.Name = webName}
}

function checkGPUSupport{
#quits if GPU isn't supported
If ($gpu.Supported -eq "No") {
$app.FailGPU
Exit
}
ElseIf ($gpu.Supported -eq "UnOfficial") {
$app.UnOfficialGPU
}
Else{}
}

function checkDriverInstalled {
#Tells user if no GPU driver is installed
if ($system.Valid_NVIDIA_Driver -eq $False) {
$app.NoDriver
}
Else{}
}

function prepareEnvironment {
#prepares working directory
$test = Test-Path -Path $system.path 
if ($test -eq $true) {
Remove-Item -path $system.Path -Recurse -Force | Out-Null
New-Item -ItemType Directory -Force -Path $system.path | Out-Null}
Else {
New-Item -ItemType Directory -Force -Path $system.path | Out-Null
}
}

function startUpdate { 
#Gives user an option to start the update, and sends messages to the user
       prepareEnvironment
       downloaddriver
       InstallDriver
       rebootlogic
}

function setnvsmi {
#downloads script to set GPU to WDDM if required
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/parsec-cloud/Cloud-GPU-Updater/master/Additional%20Files/NVSMI.ps1", $($system.Path) + "\NVSMI.ps1") 
Unblock-File -Path "$($system.Path)\NVSMI.ps1"
}

function setnvsmi-shortcut{
#creates startup shortcut that will start the script downloaded in setnvsmi
Write-Output "Create NVSMI shortcut"
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup\NVSMI.lnk")
$ShortCut.TargetPath="powershell.exe"
$ShortCut.Arguments='-WindowStyle hidden -ExecutionPolicy Bypass -File "C:\ParsecTemp\Drivers\NVSMI.ps1"'
$ShortCut.WorkingDirectory = "C:\ParsecTemp\Drivers";
$ShortCut.WindowStyle = 0;
$ShortCut.Description = "Create NVSMI shortcut";
$ShortCut.Save()
}

function DownloadDriver {
if (($gpu.supported -eq "UnOfficial") -eq $true) {
(New-Object System.Net.WebClient).DownloadFile($($($URL.GoogleGRID).links | Where-Object href -like *server2016_64bit_international.exe*).href, "C:\ParsecTemp\Drivers\GoogleGRID.exe")
}
Else {
#downloads driver from nvidia.com
$Download.Link = Invoke-WebRequest -Uri $gpu.url -Method Get -UseBasicParsing | select @{N='Latest';E={$($_.links.href -match"www.nvidia.com/download/driverResults.aspx*")[0].substring(2)}}
$download.Direct = Invoke-WebRequest -Uri $download.link.latest -Method Get -UseBasicParsing | select @{N= 'Download'; E={"http://us.download.nvidia.com" + $($_.links.href -match "/content/driverdownload*").split('=')[1].split('&')[0]}}
(New-Object System.Net.WebClient).DownloadFile($($download.direct.download), $($system.Path) + "\NVIDIA_" + $($gpu.web_driver) + ".exe")
}
}

function installDriver {
#installs driver silently with /s /n arguments provided by NVIDIA
$DLpath = Get-ChildItem -Path $system.path -Include *exe* -Recurse | Select-Object -ExpandProperty Name
Start-Process -FilePath "$($system.Path)\$dlpath" -ArgumentList "/s /n" -Wait }

#setting up arrays below
$url = @{}
$download = @{}
$app = @{}
$gpu = @{Device_ID = installedGPUID}
$system = @{Valid_NVIDIA_Driver = ValidDriver; OS_Version = osVersion; OS_Reboot_Required = RequiresReboot; Date = get-date; Path = "C:\ParsecTemp\Drivers"}

function rebootLogic {
#checks if machine needs to be rebooted, and sets a startup item to set GPU mode to WDDM if required
if ($system.OS_Reboot_Required -eq $true) {
    if ($GPU.NV_GRID -eq $false)
    {
    start-sleep -s 10
    Restart-Computer -Force} 
    ElseIf ($GPU.NV_GRID -eq $true) {
    setnvsmi
    setnvsmi-shortcut
    start-sleep -s 10
    Restart-Computer -Force}
    Else{}
}
Else {
    if ($gpu.NV_GRID -eq $true) {
    setnvsmi
    setnvsmi-shortcut
    start-sleep -s 10
    Restart-Computer -Force}
    ElseIf ($gpu.NV_GRID -eq $false) {
    }
    Else{}
}
}

#remove Windows Proxy
clear-proxy

#fix gpu
EnableDisabledGPU
prepareEnvironment
queryOS
querygpu
querygpu
checkGPUSupport
querygpu

if(($gpu.supported -eq "Yes") -or ($gpu.supported -eq "UnOfficial")) {}
Else {
Write-host "There is no GPU or it is unsupported"
Exit
}

if ($gpu.driver_version -eq $null) {
write-host "No Driver"
startUpdate
}
Else{"Continue"}
if ($gpu.current_mode -eq "TCC") {
write-host "Change Driver Mode"
setnvsmi
setnvsmi-shortcut
shutdown /r -t 0}
Else {}

