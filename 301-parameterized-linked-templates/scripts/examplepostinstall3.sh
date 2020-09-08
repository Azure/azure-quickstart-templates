#!/bin/bash
echo SetupJump.sh was run at $(date) | tee -a /var/log/ExamplePostInstall3.log
echo SetupJump.sh was called with arguements: "$@" | tee -a /var/log/ExamplePostInstall3.log