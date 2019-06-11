powershell.exe -noprofile -nologo -command "Import-Module '%~dp0AzRMTester.psd1'; Test-AzureRMTemplate %*; if ($error.Count) { exit 1}"
