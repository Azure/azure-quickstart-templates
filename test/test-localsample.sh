#!/usr/bin/env bash
pwsh -noprofile -nologo -command "$0/../ci-scripts/Test-LocalSample.ps1 $@ ; if (\$error.Count) { exit 1}"
