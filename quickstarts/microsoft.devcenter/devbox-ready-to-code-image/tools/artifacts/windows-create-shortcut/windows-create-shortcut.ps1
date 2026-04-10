Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $ShortcutName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $ShortcutTargetPath,

    [Parameter(Mandatory=$false)]
    $ShortcutArguments,

    [Parameter(Mandatory=$false)]
    $ShortcutWorkingDirectory,

    [Parameter(Mandatory=$false)]
    $ShortcutIcon,

    # defaults to Public Desktop if not provided
    [Parameter(Mandatory=$false)]
    $ShortcutDestinationPath = [System.Environment]::GetFolderPath("CommonDesktopDirectory"),

    [Parameter(Mandatory=$false)]
    $EnableRunAsAdmin = $false
)

# Create destination directory if it doesn't exist
$newShortcutPath = $ShortcutDestinationPath + "\" + $ShortcutName + ".lnk"
if (-not (Test-Path -Path $ShortcutDestinationPath))
{
    New-Item -ItemType 'directory' -Path $ShortcutDestinationPath
}

# wscript.shell CreateShortcut documentation: https://docs.microsoft.com/en-us/troubleshoot/windows-client/admin-development/create-desktop-shortcut-with-wsh

# create the shortcut only if one doesn't already exist.
if (-not (Test-Path -Path $newShortcutPath))
{
    # create the wshshell obhect
    $shell = New-Object -ComObject wscript.shell
        
    $newShortcut = $shell.CreateShortcut($newShortcutPath)
    $newShortcut.TargetPath = $ShortcutTargetPath

    # save the shortcut
    Write-Host "Creating specified shortcut. Shortcut file: '$newShortcutPath'. Shortcut target path: '$($newShortcut.TargetPath)'"
    
    if ([System.String]::IsNullOrWhiteSpace($ShortcutArguments) -eq $false) 
    {
        Write-Host "Using shortcut Arguments '$ShortcutArguments'."
        $newShortcut.Arguments = $ShortcutArguments
    }

    if (-not ([System.String]::IsNullOrWhiteSpace($ShortcutIcon)))
    {
        # can be "file" or "file, index" such as "notepad.exe, 0"
        $newShortcut.IconLocation = $ShortcutIcon
    }

    if (-not ([System.String]::IsNullOrWhiteSpace($ShortcutWorkingDirectory)))
    {
        $newShortcut.WorkingDirectory = $ShortcutWorkingDirectory
    }

    $newShortcut.Save()

    if ($EnableRunAsAdmin -eq $true)
    {
        Write-Host "Enabling $newShortcutPath to Run As Admin."
        $bytes = [System.IO.File]::ReadAllBytes($newShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($newShortcutPath, $bytes)
    }
}
else
{
    Write-Warning "Specified shortcut already exists: $newShortcutPath"
}