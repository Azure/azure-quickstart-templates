$certificate = New-SelfSignedCertificate -DnsName $nodeName -CertStoreLocation "cert:\LocalMachine\My"	
#Install ARR
Invoke-Expression ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))
cinst urlrewrite -y --force
cinst iis-arr -y --force