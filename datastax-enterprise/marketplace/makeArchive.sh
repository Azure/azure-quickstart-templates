#!/usr/bin/env bash

# This is a bash script to create a zip of our archive for deployment in the marketplace

mkdir tmp
cd tmp

cp ../../extensions/* ./
cp ../../singledc/* ./

# Do this after since we're going to overwrite mainTemplate.json
cp ../mainTemplate.json ./
cp ../createUiDefinition.json ./

# Drop some files that don't need to be in the archive
rm README.md
rm deploy.sh
rm mainTemplateParameters.json

zip ../archive.zip *
cd -
rm -rf tmp

