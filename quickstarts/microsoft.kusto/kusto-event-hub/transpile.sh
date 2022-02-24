#!/bin/bash

##########################################################################
##  Transpile main.bicep into azuredeploy.json

az bicep build -f main.bicep --outfile azuredeploy.json