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

function readJSONFile(filePath) {
  var fileContents = fs.readFileSync(filePath, {
    encoding: 'utf-8'
  }).trim();
  return tryParse(filePath, fileContents);
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

function validateMetadata(metadataFilePath) {
  var metadataObject = readJSONFile(metadataFilePath);
  var metadataSchemaValidationResult = skeemas.validate(metadataObject, {
    properties: {
      itemDisplayName: {
        type: 'string',
        required: true,
        minLength: 10,
        maxLength: 60
      },
      description: {
        type: 'string',
        required: true,
        minLength: 10,
        maxLength: 1000
      },
      summary: {
        type: 'string',
        required: true,
        minLength: 10,
        maxLength: 200
      },
      githubUsername: {
        type: 'string',
        required: true,
        minLength: 2
      },
      dateUpdated: {
        type: 'string',
        required: true,
        minLength: 10
      },
      icon: {
        type: 'string',
        enum: [
          'api',
          'blankTemplate',
          'cdnStorage',
          'cdnWebsite',
          'docker',
          'documentDB',
          'logic',
          'serviceFabric',
          'ubuntu',
          'vmss',
          'windowsVM'
        ]
      }
    },
    additionalProperties: false
  });

  var metadataSchemaValidationErrorMessages = '';
  metadataSchemaValidationResult.errors.forEach(function (error) {
    metadataSchemaValidationErrorMessages += (metadataFilePath + ' - ' + error.context + ':' + error.message + '\n');
  });
  assert(metadataSchemaValidationResult.valid, metadataSchemaValidationErrorMessages);

  // validate description has no html
  assert(!(/<[a-z][\s\S]*>/i).test(metadataObject.description), metadataFilePath + ' - Contains possible HTML elements which are not allowed');
  // validate date
  var date = new Date(metadataObject.dateUpdated);
  var currentTime = new Date(Date.now());
  assert(!isNaN(date.getTime()), metadataFilePath + ' - dateUpdated field should be a valid date in the format YYYY-MM-DD');
  // validate date is not in future
  assert(date < currentTime, metadataFilePath + ' - dateUpdated field should not be in the future');
}

function validateParameters(parametersFilePath, parametersObject) {
  assert(isDefined(parametersObject.$schema), parametersFilePath + ' - Expected a \'.$schema\' field within the parameters file');

  assert(parametersObject.parameters, parametersFilePath + ' - Expected a \'.parameters\' field within the parameters file');
  for (var parameterName in parametersObject.parameters) {
    if (typeof parameterName === 'string') {
      var parameterObject = parametersObject.parameters[parameterName];
      assert(isDefined(parameterObject.value) || isDefined(parameterObject.reference),
        parametersFilePath + ' - Parameter \"' + parameterName + '\" should have a \"value\" or \"reference\" property.');
    }
  }
}

function validateTemplate(requestBody, templateFilePath) {
  var validatePromise;
  if (process.env.VALIDATION_SKIP_VALIDATE) {
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
  if (process.env.VALIDATION_SKIP_DEPLOY) {
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

describe('Template', function () {
  this.timeout(7100 * 1000);

  var modifiedDirectories = {};
  if (process.env.VALIDATE_MODIFIED_ONLY) {
    // we automatically reset to the beginning of the commit range
    // so this includes all file paths that have changed for the CI run
    assert(process.env.TRAVIS_COMMIT_RANGE, 'VALIDATE_MODIFIED_ONLY requires TRAVIS_COMMIT_RANGE to be set to [START_COMMIT_HASH]...[END_COMMIT_HASH]');

    const modifiedPaths = childProcess.execSync('git diff --name-only ' + process.env.TRAVIS_COMMIT_RANGE, {
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
      !fs.existsSync(path.join(fileEntryPath, '.ci_skip')) &&
      // if we are only validating modified templates
      // only add test if this directory template has been modified
      (!process.env.VALIDATE_MODIFIED_ONLY || modifiedDirectories[fileEntry]);
  });

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
            var metadataFilePath = path.join(testDirectory, 'metadata.json');
            var readmeFilePath = path.join(testDirectory, 'README.md');

            [templateFilePath, parametersFilePath, metadataFilePath, readmeFilePath].forEach(function (filePath) {
              // Vaidates that the expected file paths exist
              assert(fs.existsSync(filePath), 'The file ' + filePath + ' is missing.');
            });

            validateMetadata(metadataFilePath);

            var parametersObject = readJSONFile(parametersFilePath);
            validateParameters(parametersFilePath, parametersObject);

            var requestBody = {
              template: readJSONFile(templateFilePath),
              parameters: parametersObject
            };
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
});
