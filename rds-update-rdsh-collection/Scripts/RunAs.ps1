[cmdletbinding()]
param(
    [string]$user,
    [string]$pwd,

    [string]$command
    )

"`n$(get-date -f o)  executing command"
"> $command"
"as '$user' ..."

$creds = new-object System.Management.Automation.PSCredential ($user, (convertto-securestring $pwd -asplaintext -force))

start-process -Credential $creds powershell.exe "-command &{ $command }" -rse "runas.error.log" -rso "runas.log"

"`n$(get-date -f o)  execute command done."