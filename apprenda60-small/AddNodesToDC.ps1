param
(
	$domainname = "apprenda.local",
	$domaincontrollerserver = $(throw "domain controller info is required"),
    $domainUserName = $(throw "domain credential is required"),
    $domainPassword = $(throw "domain password is required")
)
$secpw = ConvertTo-SecureString $domainPassword -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($domainUserName, $secpw)
Add-Computer -DomainName $domainname -Server $domaincontrollerserver -Credential $pscredential -Force 