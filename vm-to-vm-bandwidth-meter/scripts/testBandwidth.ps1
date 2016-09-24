Param(
  [string]$TestIPPort,
  [int]$TestNumber,
  [string]$PacketSize
)

$AppFolder = "bandwidthmeter"
$AppPath = [Environment]::GetFolderPath("CommonApplicationData")+"\bandwidthmeter"

$PsToolsSourceURL = "https://download.sysinternals.com/files/PSTools.zip"
$PsToolsArchive = $AppPath+"\PSTools.zip"
$PsPingFileName = "psping.exe"

if (!(Test-Path $AppPath)){
    mkdir $AppPath | Out-Null
    Invoke-WebRequest $PsToolsSourceURL -OutFile $PsToolsArchive

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($PsToolsArchive, $AppPath)
    rm $PsToolsArchive 
}


cd $AppPath
.\psping.exe -b -q -accepteula -l $PacketSize -n $TestNumber $TestIPPort | Select-String -Pattern "Minimum = *"