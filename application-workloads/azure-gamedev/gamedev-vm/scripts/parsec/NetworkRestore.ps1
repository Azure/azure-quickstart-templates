function Remove-Razer-Startup {
if (((Get-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run).GetValue("Razer Synapse") -ne $null) -eq $true) 
{Remove-ItemProperty -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Razer Synapse"
"Removed Startup Item from Razer Synapse"}
Else {"Razer Startup Item not present"}
}
Remove-Razer-Startup
function checkGPUstatus {
$getdisabled = Get-WmiObject win32_videocontroller | Where-Object {$_.name -like '*NVIDIA*' -and $_.status -like 'Error'} | Select-Object -ExpandProperty PNPDeviceID
if ($getdisabled -ne $null) {"Enabling GPU"
$var = $getdisabled.Substring(0,21)
$arguement = "/r enable"+ ' ' + "*"+ "$var"+ "*"
Start-Process -FilePath "C:\ParsecTemp\Apps\devcon.exe" -ArgumentList $arguement
}
Else {"Device is enabled"}
}
function DriverInstallStatus {
$checkdevicedriver = Get-WmiObject win32_videocontroller | Where-Object {$_.PNPDeviceID -like '*VEN_10DE*'}
if ($checkdevicedriver.name -eq "Microsoft Basic Display Adapter") {Write-output "Driver not installed"
}
Else {checkGPUStatus}
}
DriverInstallStatus


function check-nvidia {
$nvidiasmiarg = "-i 0 --query-gpu=driver_model.current --format=csv,noheader"
$nvidiasmidir = "c:\program files\nvidia corporation\nvsmi\nvidia-smi" 
$nvidiasmiresult = Invoke-Expression "& `"$nvidiasmidir`" $nvidiasmiarg"
$nvidiadriverstatus = if($nvidiasmiresult -eq "WDDM") 
{"GPU Driver status is good"
}
ElseIf($nvidiasmiresult -eq "TCC")
{Write-Output "The GPU has incorrect mode TCC set - setting WDDM"
$nvidiasmiwddm = "-g 0 -dm 0"
$nvidiasmidir = "c:\program files\nvidia corporation\nvsmi\nvidia-smi" 
Invoke-Expression "& `"$nvidiasmidir`" $nvidiasmiwddm"}
Else{}
$nvidiadriverstatus}

check-nvidia

#set ip and dns to dhcp
function set-dhcp
{
$global:interfaceindex = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object ifindex -ExpandProperty ifindex
$Global:interfacename = Get-NetIPInterface -InterfaceIndex $interfaceindex -AddressFamily IPv4 | select interfacealias -ExpandProperty interfacealias
$Global:setdhcp = "netsh interface ip set address '$interfacename' dhcp" 
$Global:setdnsdhcp = "netsh interface ip set dns '$interfacename' dhcp" 
Invoke-expression -command "$setdhcp"
Invoke-expression -command "$setdnsdhcp"
}
#enable adapter if required
function Enable-Adapter
{
Get-NetAdapter |? status -NE Enabled | Enable-NetAdapter
}
$getdisabledadapters = Get-NetAdapter |? status -ne enabled
#query device and perform required fix
$networkadapterstatus = if($getdisabledadapters -ne $null)
{"no adapter found - enabling disabled adapters and setting dhcp"
enable-adapter
set-dhcp
}
else
{"Resetting DHCP"
set-dhcp
}

$networkadapterstatus
