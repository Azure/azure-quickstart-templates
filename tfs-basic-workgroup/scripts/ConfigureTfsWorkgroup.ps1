curl 'https://go.microsoft.com/fwlink/?LinkId=857132' -o tfsserver2017.3.1_enu.iso

$iso = Mount-DiskImage -ImagePath (Resolve-Path "tfsserver2017.3.1_enu.iso")

$isoDrive = ($iso | Get-Volume).DriveLetter

Start-Process "${isoDrive}:\TfsServer2017.3.1.exe" -ArgumentList '/Passive','/NoRestart' -Wait

Dismount-DiskImage -ImagePath  $iso.ImagePath

Restart-Computer

& 'C:\Program Files\Microsoft Team Foundation Server 15.0\Tools\tfsconfig.exe' unattend /configure /type:Basic /inputs:InstallSqlExpress=True

Restart-Computer
