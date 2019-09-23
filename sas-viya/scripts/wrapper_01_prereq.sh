#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
#set -x
#set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "/sas/install/env.ini"
export TOUCHPOINT_FILE="$TOUCHPOINT_PREREQUISITES"

"${ScriptDirectory}/runners/wrapper__base.sh"


