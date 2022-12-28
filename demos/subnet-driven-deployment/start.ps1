#
# start.ps1
#
wevtutil.exe set-log �Microsoft-Windows-Dsc/Analytic� /q:true /e:true           # https://blogs.msdn.microsoft.com/powershell/2014/01/03/using-event-logs-to-diagnose-errors-in-desired-state-configuration/
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
