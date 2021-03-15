#
# Generate template README.md with PSDocs
#

# Notes:
# - By default, only documents for templates changed within the current branch are generated.
# - To generate documents for all template run with the -All switch.
#
# To run the following from PowerShell:
# ./.ps-docs/run.ps1

[CmdletBinding()]
param (
    # Generate documentation for all templates.
    [Parameter(Mandatory = $False)]
    [Switch]$All = $False
)

$minimumVersion = '0.2.0';
if ($Null -eq (Get-InstalledModule -Name PSDocs.Azure -MinimumVersion $minimumVersion -ErrorAction SilentlyContinue)) {
    $Null = Install-Module -Name PSDocs.Azure -MinimumVersion $minimumVersion -Force -Scope CurrentUser;
}

Import-Module PSDocs.Azure -MinimumVersion $minimumVersion;

$branchFilter = @(git diff master --name-only --diff-filter=AMU | ForEach-Object {
    Join-Path -Path $PWD -ChildPath $_;
})

# Scan for Azure template file recursively in the templates/ directory
Get-AzDocTemplateFile -Path . -InputPath 'azuredeploy.json' | Where-Object { $All -or $_ -in $branchFilter } | ForEach-Object {
    $template = Get-Item -Path $_.TemplateFile;
    Invoke-PSDocument -Module PSDocs.Azure -OutputPath $template.Directory.FullName -InputObject $template.FullName -InstanceName 'README';
}
