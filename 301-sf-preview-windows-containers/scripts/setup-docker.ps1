Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "datadisk" -Confirm:$false

New-Item -Path "F:\Docker" -Type Directory
Set-Content "C:\ProgramData\docker\config\daemon.json" '{"graph": "F:\\Docker"}'
Stop-Process -ProcessName dockerd -Force
Start-Sleep -s 1
Remove-Item -Path "C:\ProgramData\docker\docker.pid"
Start-Sleep -s 1
Start-Service -DisplayName "Docker"
Start-Sleep -s 1

# Might want to pre-fetch your docker image as well, and this can be done with the below example.
# docker login --username <example-user> --password <example-password> <example-registry>
# docker pull <example-registry>/hello/hello-world

Write-Host "Completed..."