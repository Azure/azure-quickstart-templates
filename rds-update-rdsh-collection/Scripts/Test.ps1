#
# Test.ps1
#

[cmdletbinding()]
param(
	[string]$username,
	[string]$password 
	)

write-host "username: $username;  password:  $password"

whoami