#usage getprocess.ps1 filename.txt foldername

param
(
      [string]$fileName = $null,
      [string]$folderName = $null
)

if(!$fileName) {
 throw "FileName not specified"
}

if(!$folderName) {
 throw "FolderName not specified"
}

$folderPath = "C:\" + $folderName + "\"
$absolutePath = $folderPath + $filename
New-Item -Path $folderPath -Name $filename -ItemType File -Force
Get-Process > $absolutePath
