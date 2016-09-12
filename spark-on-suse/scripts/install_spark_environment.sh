#!/bin/bash

echo "I am working"

install_prerequisites()
{
	echo "Updating Suse"
	JAVAC=$(which javac)
	if [[ -z $JAVAC ]]; then
		echo "Installing OpenJDK"
		sudo zypper install -y java-1_8_0-openjdk
	fi
}

install_prerequisites


