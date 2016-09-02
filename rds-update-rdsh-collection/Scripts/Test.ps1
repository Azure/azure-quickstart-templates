#
# Test.ps1
#

[cmdletbinding()]
param(
	[string]$username,
	[string]$password 
	)

get-date

$collection = 'Desktop Collection'

write-host "username: $username;  password:  $password"

whoami

ipmo remotedesktop

get-rdserver

get-rdsessionhost -collectionname $collection

get-rdusersession -collectionname $collection

