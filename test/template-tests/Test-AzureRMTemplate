#!/bin/sh
powershell -noprofile -nologo -command ". .\Test-AzureRMTemplate.ps1; Import-Module Pester; Test-AzureRMTemplate $@ ; if (\$error.Count) { exit 1}"
