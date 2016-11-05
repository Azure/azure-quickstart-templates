 Param(
  [string]$FQDN,
  [string]$blobendpoint,
  [string]$key
)

$key | out-file c:\users\key.txt
 
 Add-WindowsFeature -Name RDS-Gateway -IncludeAllSubFeature
 Add-WindowsFeature -Name 
 Import-Module RemoteDesktopServices
 CD RDS:\GatewayServer\CAP
 new-item -Name RDGWCAP -UserGroups 'Administrators@BUILTIN' -AuthMethod 1
 CD RDS:\GatewayServer\RAP
 new-item -Name RDGWRAP -UserGroups 'Administrators@BUILTIN' -ComputerGroupType 2

 $cert= New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName $FQDN

 Set-Item -Path RDS:\GatewayServer\SSLCertificate\Thumbprint -Value $cert.Thumbprint
 get-childitem cert:\localmachine\my | where-object { $_.Subject -eq "CN=$FQDN" } | Export-Certificate -FilePath 'c:\users\rdgw.cer'

 CD C:\

invoke-webrequest http://aka.ms/downloadazcopy -OutFile azcopy.msi
.\azcopy.msi /quiet
Start-Sleep -s 60

cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AZCopy"
.\AzCopy.exe /Source:C:\users /Dest:$blobendpoint /DestKey:$key /Pattern:rdgw.cer

