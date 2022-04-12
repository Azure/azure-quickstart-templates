param (
    [string]$storageAccount, 
    [string]$storageAccountKey,    
    [string]$fileShareName)

if ($storageAccount -and $storageAccountKey -and $fileShareName)
{
    Add-Content 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\mountfileshare.cmd' "@ECHO OFF`r`necho Mounting Azure Storage File Share"
    Add-Content 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\mountfileshare.cmd' "cmdkey /add:$storageAccount.file.core.windows.net /user:localhost\$storageAccount /pass:`"$storageAccountKey`""
    Add-Content 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\mountfileshare.cmd' "net use S: `"\\$storageAccount.file.core.windows.net\$fileShareName`" /persistent:yes"
    Add-Content 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\mountfileshare.cmd' "del `"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\mountfileshare.cmd`""
}