# Run static validation checks for templates

This folder contains mocha tests, that runs static checks against a solution template folder containing mainTemplate.json, createUiDefinition.json and other template artifacts like nested templates, etc. A sample solution template folder named "sample-template" is included, that can be used to run the checked in tests under the "test" folder.

## Prerequisites

- [Install](https://nodejs.org/en/) nodejs with npm

## Setup

- navigate to the "template-validation-tests" folder
- npm install

## Running all tests

To run all tests
- npm --folder=/path/to/solutiontemplatefolder run all. For instance,
```
npm --folder=sample-template run all
```

## Running json validation tests

To check if all the json files in a given folder are valid
- npm --folder=/path/to/solutiontemplatefolder run validateJson. For instance,
```
npm --folder=sample-template run validateJson
```

## Running createUiDefinition tests

To run just the tests for createUiDefinition.json file
```
npm --folder=sample-template run createUi
```

## Running template tests

To run just the tests for template files (mainTemplate.json and any nested template json files included in the folder)
```
npm --folder=sample-template run template
```

## Other miscellaneous files in this folder

buildpackage.zip, Gruntfile.js, CreateBuildPackage.ps1 and SetBranchNameVariable.ps1 files are NOT required to run tests locally. These are files used by as part of a CI/CD pipeline.