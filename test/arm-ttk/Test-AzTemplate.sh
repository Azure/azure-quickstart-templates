#!/bin/sh
pwsh -noprofile -nologo -command "Import-Module '$(dirname $(readlink -f $0))/arm-ttk.psd1'; Test-AzTemplate $@ ; if (\$error.Count) { exit 1}"
