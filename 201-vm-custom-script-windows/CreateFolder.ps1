<# Custom Script for Windows #>
$folderName = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")            
New-Item -itemType Directory -Path d:\ -Name $folderName
