[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((new-object net.webclient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install sql-server-management-studio -y
