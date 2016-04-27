# client vm setup script - run on client vm within a private cluster

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

echo "client start" *>> "$env:windir\Temp\MDCSLog.log"
$MyInvocation | Out-String *>> "$env:windir\Temp\MDCSLog.log"

$matlabroot = FindMatlabRoot
$matlablicenseroot = $matlabroot + "\licenses" 
$matlablicensefile = $matlabroot + "\licenses\license_info.xml"
# create folder
mkdir $matlablicenseroot *>> "$env:windir\Temp\MDCSLog.log"

# touch license file
$myString = @"
<?xml version="1.0" encoding="UTF-8"?>
<root>
    <ActivationEntry hostname="*" idnumber="1"
        matlabroot="*" user="*">
        <licmode>online</licmode>
    </ActivationEntry>
</root>
"@

$myString | Out-File -Encoding ascii $matlablicensefile

#create shortcut
$TargetFile = $matlabroot + "\bin\matlab.exe"
$ShortcutFile = "C:\Users\Public\Desktop\MATLAB.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

mkdir "c:\mdcsshare" *>> "$env:windir\Temp\MDCSLog.log"
net share mdcsshare=c:\mdcsshare /remark:"mdcs cluster data staging share" /grant:everyone`,FULL *>> "$env:windir\Temp\MDCSLog.log"
