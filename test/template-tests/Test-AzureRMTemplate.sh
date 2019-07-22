#!/bin/sh
powershell -noprofile -nologo -command "Import-Module '$(dirname $(readlink -f $0))/AzRMTester.psd1'; Test-AzureRMTemplate $@ ; if (\$error.Count) { exit 1}"