#!/bin/bash
if [[ -e "$HOME/.profile" ]]; then
	. $HOME/.profile
fi
if [[ -e "$HOME/.bash_profile" ]]; then
	. $HOME/.bash_profile
fi
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#set -x
#set -v

RETURN_FILE="$1"
if [[ -z "$RETURN_FILE" ]]; then
RETURN_FILE="/tmp/install_runner.out"
fi

#FILE_OF_RECORD="$2"
#if [[ -z "$FILE_OF_RECORD" ]]; then
#FILE_OF_RECORD="/tmp/install_runner.log"
#fi

"${ScriptDirectory}/install_runner.sh" "${RETURN_FILE}"
ret="$?"
if [[ ! -z "${RETURN_FILE}" ]]; then
    echo "${ret}" > "${RETURN_FILE}"
fi
if [[ "${ret}" -ne "0" ]]; then
    exit ${ret}
fi
