#Script based on https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/visual-studio-dev-vm-chocolatey/scripts/SetupChocolatey.ps1
param([Parameter(Mandatory=$true)][string]$chocoPackages)

#Changing ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

#Change securoty protocol
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Choco
$sb = { iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) }
Invoke-Command -ScriptBlock $sb 

$sb = { Set-ItemProperty -path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -name EnableLua -value 0 }
Invoke-Command -ScriptBlock $sb 

#Install Chocolatey Packages
$chocoPackages.Split(";") | ForEach {
    $command = "cinst " + $_ + " -y -force"
    $command 
    $sb = [scriptblock]::Create("$command")

    # Use the current user profile
    Invoke-Command -ScriptBlock $sb -ArgumentList $chocoPackages 
}

#Install NDI-Runtime via Powershell as choco package not validated
$url = "https://ndi.palakis.fr/runtime/ndi-runtime-4.5.1-Windows.exe"

$path=split-path $MyInvocation.MyCommand.path
$spath= "$path\ndi-runtime-4.5.1-Windows.exe"
	
Invoke-WebRequest -Uri $url -OutFile $spath
Start-Process -FilePath $spath -Verb runAs -ArgumentList '/SILENT','/v"/qn"'


#Install NDI-OBS via zip package

# Find install location from registry, but fall back to ProgramFiles 
$installPath = "$ENV:ProgramFiles\obs-studio"
$key = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\OBS Studio' -ErrorAction SilentlyContinue)
if ($key) {
  $installPath = $key.'(default)'
}

#Downoload last zip package with obs-ndi
$url = "https://github.com/Palakis/obs-ndi/releases/download/4.9.0/obs-ndi-4.9.0-Windows.zip"
$path=split-path $MyInvocation.MyCommand.path
$spath= "$path\obs-ndi-4.9.0-Windows.zip"

Invoke-WebRequest -Uri $url -OutFile $spath
Expand-Archive -LiteralPath $spath -DestinationPath $installPath