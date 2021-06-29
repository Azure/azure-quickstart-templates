#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi

# set -x
# set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
find_file="${ScriptDirectory}/../file_tree.txt"

rm -f "$find_file"
pushd "$ScriptDirectory/.."
while read line; do 
	chmod_attr="$(stat --format '%a' $line)"
	echo "${line:1}|${chmod_attr}">>"$find_file" 
done <<<"$(find . -type f)"
popd
