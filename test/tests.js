'use strict';

/*global describe, it*/
var assert = require('assert');
var colors = require('mocha/lib/reporters/base').colors;
var debug = require('debug')('validator');
var childProcess = require('child_process');
var fs = require('fs');
var parallel = require('mocha.parallel');
var path = require('path');
var RSVP = require('rsvp');
var skeemas = require('skeemas');
var unirest = require('unirest');

// setup mocha color scheme
// 32 = console code for green
colors.pass = 32;

// Tries to parse a json string and asserts with a friendly
// message if something is wrong
function tryParse(fileName, jsonStringData) {
  var object;

  try {
    object = JSON.parse(jsonStringData);
  } catch (e) {
    assert(false, fileName + ' is not valid JSON. Copy and paste the contents to https://jsonformatter.curiousconcept.com/ and correct the syntax errors. Error: ' + e.toString());
  }

  return object;
}

var filePathExistsMap = {};

function fileExists(filePath) {
  if (!(filePath in filePathExistsMap)) {
    filePathExistsMap[filePath] = fs.existsSync(filePath);
  }
  return filePathExistsMap[filePath];
}

var jsonFileContentsMap = {};

function readJSONFile(filePath) {
  if (!(filePath in jsonFileContentsMap)) {
    if (fileExists(filePath)) {
      var fileContents = fs.readFileSync(filePath, {
        encoding: 'utf-8'
      });
      jsonFileContentsMap[filePath] = tryParse(filePath, fileContents.trim());
    } else {
      jsonFileContentsMap[filePath] = null;
    }
  }
  return jsonFileContentsMap[filePath];
}

function isDefined(value) {
  return value !== null && value !== undefined && value !== '';
}

// this is required to keep travis from timing out
// due to lack of console output
function timedOutput(onOff, intervalObject) {
  if (onOff) {
    return setInterval(function () {
      process.stdout.write('...');
    }, 60 * 1000);
  } else {
    clearTimeout(intervalObject);
  }
}

function getEnvironmentVariableBoolean(variableName, defaultValue) {
  var result = defaultValue;

  if (variableName) {
    var variableValue = process.env[variableName];
    if (variableValue) {
      if (typeof variableValue === 'string') {
        result = (variableValue.toLowerCase() === 'true');
      }
    }
  }

  return result;
}

function validateTemplate(requestBody, templateFilePath) {
  var validatePromise;
  if (getEnvironmentVariableBoolean('VALIDATION_SKIP_VALIDATE')) {
    validatePromise = RSVP.resolve({});
  } else {
    // Calls a remote url which will validate the template and parameters
    if (process.env.TRAVIS_PULL_REQUEST &&
      process.env.TRAVIS_PULL_REQUEST !== 'false') {
      requestBody.pull_request = process.env.TRAVIS_PULL_REQUEST;
    }

    var templateObject = requestBody.template;

    // validate the template paramters, particularly the description field
    assert(templateObject.parameters, 'Expected a \'.parameters\' field within the deployment template');
    for (var parameterName in templateObject.parameters) {
      if (typeof parameterName === 'string') {
        assert(templateObject.parameters[parameterName].metadata,
          templateFilePath + ' - Parameter \"' + parameterName + '\" is missing its \"metadata\" property');
        assert(templateObject.parameters[parameterName].metadata.description,
          templateFilePath + ' - Parameter \"' + parameterName + '\" is missing its \"description\" field within the metadata property');
      }
    }

    validatePromise = new RSVP.Promise(function (resolve, reject) {
      unirest.post(process.env.VALIDATION_HOST + '/validate')
        .type('json')
        .send(JSON.stringify(requestBody))
        .end(function (response) {
          if (response.status !== 200) {
            reject(response);
          } else {
            resolve(response.body);
          }
        });
    });
  }
  return validatePromise;
}

function deployTemplate(requestBody) {
  var deployPromise;
  if (getEnvironmentVariableBoolean('VALIDATION_SKIP_DEPLOY')) {
    deployPromise = RSVP.resolve({});
  } else {
    if (process.env.TRAVIS_PULL_REQUEST &&
      process.env.TRAVIS_PULL_REQUEST !== 'false') {
      requestBody.pull_request = process.env.TRAVIS_PULL_REQUEST;
    }

    var intervalObj = timedOutput(true);
    debug('making deploy request');

    // Calls a remote url which will deploy the template
    deployPromise = new RSVP.Promise(function (resolve, reject) {
      return unirest.post(process.env.VALIDATION_HOST + '/deploy')
        .type('json')
        .timeout(3600 * 1000) // Templates can take a long time to deploy, so set the timeout to 1 hour
        .send(JSON.stringify(requestBody))
        .end(function (response) {
          timedOutput(false, intervalObj);
          debug(response.status);
          debug(response.body);

          // 202 is the long poll response
          // anything else is really bad
          if (response.status !== 202) {
            reject(response.body);
          }

          if (response.body.result === 'Deployment Successful') {
            resolve(response.body);
          } else {
            reject(response.body);
          }
        });
    });
  }
  return deployPromise;
}

function assertFileExists(filePath) {
  assert(fileExists(filePath), filePath + ' should exist.');
}

function itExists(filePath) {
  it('exists', function () {
    assertFileExists(filePath);
  });
}

describe('Template', function () {
  this.timeout(7100 * 1000);

  var validateModifiedOnly = getEnvironmentVariableBoolean('VALIDATE_MODIFIED_ONLY', false);
  var runRemoteValidation = !getEnvironmentVariableBoolean('VALIDATION_SKIP_VALIDATE');
  var runRemoteDeployment = !getEnvironmentVariableBoolean('VALIDATION_SKIP_DEPLOY');

  var modifiedDirectories = {};
  if (validateModifiedOnly) {
    // we automatically reset to the beginning of the commit range
    // so this includes all file paths that have changed for the CI run
    assert(process.env.TRAVIS_COMMIT_RANGE, 'VALIDATE_MODIFIED_ONLY requires TRAVIS_COMMIT_RANGE to be set to [START_COMMIT_HASH]...[END_COMMIT_HASH]');

    var modifiedPaths = childProcess.execSync('git diff --name-only ' + process.env.TRAVIS_COMMIT_RANGE, {
      encoding: 'utf8'
    }).split('\n');
    debug(modifiedPaths);

    assert(modifiedPaths.length !== 0, 'No changes were detected in your commit. Verify you added files and try again.');

    if (modifiedPaths) {
      for (var i = 0; i < modifiedPaths.length; i += 1) {
        var modifiedDirectoryPath = path.dirname(modifiedPaths[i]);
        // don't include the top level dir
        if (modifiedDirectoryPath !== '.') {
          modifiedDirectories[modifiedDirectoryPath] = true;
        }
      }
    }
  }

  // Generates the mocha tests based on directories in the existing repo.
  var srcPath = './';
  var testDirectories = fs.readdirSync(srcPath).filter(function (fileEntry) {
    var fileEntryPath = path.join(srcPath, fileEntry);
    return fs.statSync(fileEntryPath).isDirectory() &&
      fileEntry !== '.git' &&
      fileEntry !== 'node_modules' &&
      !fileExists(path.join(fileEntryPath, '.ci_skip')) &&
      // if we are only validating modified templates
      // only add test if this directory template has been modified
      (!validateModifiedOnly || modifiedDirectories[fileEntry]);
  });

  describe('Local Validation', function () {
    testDirectories.forEach(function (testDirectory) {
      describe(testDirectory, function () {
        describe('README.md', function () {
          itExists(path.join(testDirectory, 'README.md'));
        });

        describe('metadata.json', function () {
          var metadataFilePath = path.join(testDirectory, 'metadata.json');

          itExists(metadataFilePath);

          it('matches schema', function () {
            var schemaFilePath = path.join(__dirname, 'metadata.schema.json');
            assertFileExists(schemaFilePath, 'The provided JSON schema file path "' + schemaFilePath + '" doesn\'t exist.');

            var jsonSchemaObject = readJSONFile(schemaFilePath);
            var schemaValidationResult = skeemas.validate(readJSONFile(metadataFilePath), jsonSchemaObject);

            if (!schemaValidationResult.valid) {
              var schemaValidationErrorMessages = '';
              schemaValidationResult.errors.forEach(function (error) {
                schemaValidationErrorMessages += (error.context + ':' + error.message + '\n');
              });
              assert(false, schemaValidationErrorMessages);
            }
          });

          it('No HTML in description', function () {
            var metadataObject = readJSONFile(metadataFilePath);
            var description = metadataObject.description;
            var htmlDetectionRegex = /<[a-z][\s\S]*>/i;
            assert(!(htmlDetectionRegex).test(description), metadataFilePath + ' - Contains possible HTML elements which are not allowed');
          });

          it('dateUpdated not in the future', function () {
            var metadataObject = readJSONFile(metadataFilePath);
            var date = new Date(metadataObject.dateUpdated);
            var currentTime = new Date(Date.now());
            assert(date < currentTime, metadataFilePath + ' - dateUpdated field should not be in the future');
          });
        });

        describe('Validate azuredeploy.parameters.json', function () {
          var parametersFilePath = path.join(testDirectory, 'azuredeploy.parameters.json');

          itExists(parametersFilePath);

          it('has a value or reference property for each parameter', function () {
            var parametersObject = readJSONFile(parametersFilePath);
            assert(parametersObject, 'Parameters file doesn\'t exist or isn\'t a valid JSON value.');
            assert(parametersObject.parameters, parametersFilePath + ' - Expected a \'.parameters\' field within the parameters file');
            for (var parameterName in parametersObject.parameters) {
              if (typeof parameterName === 'string') {
                var parameterObject = parametersObject.parameters[parameterName];
                assert(isDefined(parameterObject.value) || isDefined(parameterObject.reference),
                  parametersFilePath + ' - Parameter \"' + parameterName + '\" should have a \"value\" or \"reference\" property.');
              }
            }
          });
        });

        describe('azuredeploy.json', function () {
          var templateFilePath = path.join(testDirectory, 'azuredeploy.json');

          itExists(templateFilePath);
        });
      });
    });
  });

  if (runRemoteValidation || runRemoteDeployment) {
    // Group tests in chunks defined by an environment variable or by the default value.
    // we probably shouldn't deploy a ton of templates at once...
    var groupSizeMaximum = isDefined(process.env.PARALLEL_DEPLOYMENT_NUMBER) ? parseInt(process.env.PARALLEL_DEPLOYMENT_NUMBER) : 2;
    var testIndex = 0;

    var testDirectoryGroup = [];
    testDirectories.forEach(function (testDirectory) {
      testDirectoryGroup.push(testDirectory);
      testIndex += 1;

      if (testIndex === testDirectories.length || testDirectoryGroup.length === groupSizeMaximum) {
        parallel('Running ' + testDirectoryGroup.length + ' Parallel Template Validation(s)...', function () {
          testDirectoryGroup.forEach(function (testDirectory) {
            it(testDirectory, function () {
              var templateFilePath = path.join(testDirectory, 'azuredeploy.json');
              var parametersFilePath = path.join(testDirectory, 'azuredeploy.parameters.json');

              var requestBody = {
                template: readJSONFile(templateFilePath),
                parameters: readJSONFile(parametersFilePath)
              };

              if (fs.existsSync(path.join(testDirectory, 'prereqs'))) {
                var preReqTemplateFilePath = path.join(testDirectory, 'prereqs/prereq.azuredeploy.json');
                var preReqParametersFilePath = path.join(testDirectory, 'prereqs/prereq.azuredeploy.parameters.json');

                requestBody.preReqTemplate = readJSONFile(preReqTemplateFilePath);
                requestBody.preReqParameters = readJSONFile(preReqParametersFilePath);
              }

              return validateTemplate(requestBody, templateFilePath)
                .then(function () {
                  return deployTemplate(requestBody, templateFilePath);
                })
                .catch(function (err) {
                  var errorString = 'Template Validiation Failed. Try deploying your template with the commands:\n';
                  errorString += 'azure group template validate --resource-group (your_group_name) ';
                  errorString += ' --template-file ' + templateFilePath + ' --parameters-file ' + parametersFilePath + '\n';
                  errorString += 'azure group deployment create --resource-group (your_group_name) ';
                  errorString += ' --template-file ' + templateFilePath + ' --parameters-file ' + parametersFilePath;
                  assert(false, errorString + ' \n\nServer Error:' + JSON.stringify(err, null, 4));
                });
            });
          });
        });

        testDirectoryGroup.length = 0;
      }
    });
  }
});
