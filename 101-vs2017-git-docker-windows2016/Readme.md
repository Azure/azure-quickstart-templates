# Container Development with Visual Studio 2019 Community Edition



Build containerized applications using both docker-desktop and visual studio 2019 latest community edition. The 'docker-desktop' installation using custom script extension would take around 15 to 20 minutes.

## Applications Installed

- Visual Studio CODE 
- Visual Studio 2019 Latest Community Edition
- Git for Windows
- Docker Desktop 

Please restart the Virtual machine once deployment is completed. Once restarted, launch docker-deskop from start menu. First run of docker-desktop would deploy Virtual machine for linux containers. It might add up another 5-10 minutes.

> You might need to add current user to 'docker-user' group

```pwsh
$ Add-LocalGroupMember -Group "docker-users" -Member $Env:USERNAME
$ logoff
## Please reconnect RDP Session
```