## Import all .ps1 files to enable testing using the unit test framework
Get-ChildItem -Path $PSScriptRoot -Include '*.ps1' -Recurse | ForEach-Object {
    . $PSItem.FullName;
}
