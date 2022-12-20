#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
set -e
set -x
set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "/tmp/sasinstall.env"
export TOUCHPOINT_FILE="$TOUCHPOINT_PREORCHESTRATION"

"${ScriptDirectory}/install_runner/wrapper__base.sh"
