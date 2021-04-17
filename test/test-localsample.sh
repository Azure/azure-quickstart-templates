#!/usr/bin/env bash

READLINK=readlink
if [ "$(uname)" == "Darwin" ]; then
    READLINK=greadlink
fi
SCRIPTPATH=$(dirname $(${READLINK} -f $0))

pwsh -noprofile -nologo -command "$SCRIPTPATH/ci-scripts/Test-LocalSample.ps1 $@ ; if (\$error.Count) { exit 1}"
