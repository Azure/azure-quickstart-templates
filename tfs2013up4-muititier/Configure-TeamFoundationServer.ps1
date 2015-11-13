param(
    [boolean]$configureWss = $false,
    [boolean]$useWss = $false,
    [boolean]$useReporting = $false,
    [boolean]$useSqlAlwaysOn = $false,
    [boolean]$IsServiceAccountBuiltIn = $false,
    [string]$sqlInstance = ${Env:\COMPUTERNAME},
    [string]$urlHostName = ${Env:\COMPUTERNAME},
	[string]$setupAccountName ="contoso\tfssetup",
	[string]$setupAccountPassword ="Password#1",
    [string]$serviceAccountName = "NT Authority\Network Service",
	[string]$serviceAccountPassword= "password#1"
)

$setupPassword = ConvertTo-SecureString -String $setupAccountPassword -AsPlainText -Force
$setupCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($setupAccountName,$setupPassword)

$servicePassword = ConvertTo-SecureString -String $serviceAccountPassword -AsPlainText -Force
$serviceCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($serviceAccountName,$servicePassword)

Enable-WSManCredSSP -Role Server
Enable-WSManCredSSP -Role Client -DelegateComputer $Env:COMPUTERNAME

Invoke-Command -ComputerName $Env:COMPUTERNAME -Authentication Credssp -ScriptBlock {
	Set-Location -Path (Get-Content Env:\ProgramFiles)
	Set-Location -Path "Microsoft Team Foundation Server 12.0\Tools"

	& ".\tfsconfig.exe" unattend /configure /type:standard /inputs:"UseWss=$using:useWss;UseReporting=$using:useReporting;ConfigureWss=$false;SqlInstance=$using:sqlInstance;UseSqlAlwaysOn=$using:useSqlAlwaysOn;IsServiceAccountBuiltIn=$using:isServiceAccountBuiltIn;ServiceAccountName=$using:serviceAccountName;ServiceAccountPassword=$(($using:serviceCred).GetNetworkCredential().Password)"  /verify 2>&1 | Write-Verbose
	& ".\tfsconfig.exe" unattend /configure /type:standard /inputs:"UseWss=$using:useWss;UseReporting=$using:useReporting;ConfigureWss=$false;SqlInstance=$using:sqlInstance;UseSqlAlwaysOn=$using:useSqlAlwaysOn;IsServiceAccountBuiltIn=$using:isServiceAccountBuiltIn;ServiceAccountName=$using:serviceAccountName;ServiceAccountPassword=$(($using:serviceCred).GetNetworkCredential().Password)"  2>&1 | Write-Verbose

} -Verbose -Credential $setupCred

# start the configuration of the app-tier
# $inputArgs = "UseWss=$useWss;UseReporting=$useReporting;ConfigureWss=$false;SqlInstance=$sqlInstance;UseSqlAlwaysOn=$useSqlAlwaysOn;IsServiceAccountBuiltIn=$isServiceAccountBuiltIn;ServiceAccountName=$serviceAccountName;ServiceAccountPassword=$($serviceCred.GetNetworkCredential().Password)"
#$tfsConfigArgs = "unattend /configure /type:standard /inputs:`"$inputArgs`""
#Start-Process -FilePath ".\tfsconfig.exe" -ArgumentList $tfsConfigArgs -Credential $setupCred -Wait -WindowStyle Normal -Verbose
#tfsconfig.exe unattend /configure /type:standard /inputs:"UseWss=$useWss;UseReporting=$useReporting;ConfigureWss=$false;SqlInstance=$sqlInstance;UseSqlAlwaysOn=$useSqlAlwaysOn;IsServiceAccountBuiltIn=$isServiceAccountBuiltIn;ServiceAccountName=$serviceAccountName" /verify
