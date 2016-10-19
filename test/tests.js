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

describe('Template', function () {
  this.timeout(7100 * 1000);

  var modifiedPaths;

  if (process.env.VALIDATE_MODIFIED_ONLY) {

    // we automatically reset to the beginning of the commit range
    // so this includes all file paths that have changed for the CI run
    assert(process.env.TRAVIS_COMMIT_RANGE, 'VALIDATE_MODIFIED_ONLY requires TRAVIS_COMMIT_RANGE to be set to [START_COMMIT_HASH]...[END_COMMIT_HASH]');

    const stdout = childProcess.execSync('git diff --name-only ' + process.env.TRAVIS_COMMIT_RANGE, {
      encoding: 'utf8'
    });
    const lines = stdout.split('\n');

    modifiedPaths = {};
    for (var i = 0; i < lines.length; i += 1) {
      modifiedPaths[lines[i]] = lines[i];
    }
    debug(modifiedPaths);

    var count = 0;
    for (var i in modifiedPaths) {
      if (typeof i === 'string') {
        count += 1;
      }
    }
    assert(count !== 0, 'No changes were detected in your commit. Verify you added files and try again.');
  }

  // Generates the mocha tests based on directories in
  // the existing repo.
  const tests = [];
  var srcPath = "./";
  var directories = fs.readdirSync(srcPath).filter(function (file) {
    return fs.statSync(path.join(srcPath, file)).isDirectory();
  });
  debug(modifiedPaths);
  var modifiedDirs = {};

  for (var k in modifiedPaths) {
    if (typeof k === 'string') {
      // don't include the top level dir
      if (path.dirname(k) === '.') {
        continue;
      }
      modifiedDirs[path.dirname(k)] = true;
    }
  }
  debug('modified dirs:');
  debug(modifiedDirs);
  directories.forEach(function (dirName) {
    // exceptions
    if (dirName === '.git' ||
      dirName === 'node_modules') {
      return;
    }

    if (fs.existsSync(path.join(dirName, '.ci_skip'))) {
      return;
    }
    var templatePath = path.join(dirName, 'azuredeploy.json'),
      paramsPath = path.join(dirName, 'azuredeploy.parameters.json'),
      metadataPath = path.join(dirName, 'metadata.json'),
      readmePath = path.join(dirName, 'README.md');

    // if we are only validating modified templates
    // only add test if this directory template has been modified
    if (modifiedPaths && !modifiedDirs[dirName]) {
      return;
    }

    tests.push({
      args: [templatePath, paramsPath, metadataPath, readmePath],
      expected: true
    });
  });

  debug('created tests:');
  debug(tests);

  // Group tests in chunks defined by an environment variable or by the default value.
  // we probably shouldn't deploy a ton of templates at once...
  const testGroups = [];
  var groupIndex = 0;
  var counter = 0;
  var groupSize = process.env.PARALLEL_DEPLOYMENT_NUMBER || 2;
  tests.forEach(function (test) {
    if (!testGroups[groupIndex]) {
      testGroups[groupIndex] = [];
    }

    testGroups[groupIndex].push(test);
    counter += 1;

    if (counter % groupSize === 0) {
      groupIndex += 1;
    }
  });

  testGroups.forEach(function (tests) {
    parallel('Running ' + tests.length + ' Parallel Template Validation(s)...', function () {
      tests.forEach(function (test) {
        var templateFilePath = test.args[0];
        var parametersFilePath = test.args[1];
        var metadataFilePath = test.args[2];

        it(templateFilePath + ' & ' + parametersFilePath + ' should be valid', function () {
          // validate template files are in correct place
          test.args.forEach(function (filePath) {
            // Vaidates that the expected file paths exist
            assert(fs.existsSync(filePath), 'The file ' + filePath + ' is missing.');
          });

          var metadataFileContents = fs.readFileSync(metadataFilePath, { encoding: 'utf-8' }).trim();
          var metadataObject = tryParse(metadataFilePath, metadataFileContents);
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


          var parametersFileContents = fs.readFileSync(parametersFilePath, { encoding: 'utf-8' }).trim();
          var parametersObject = tryParse(parametersFilePath, parametersFileContents);

          assert(isDefined(parametersObject.$schema), parametersFilePath + ' - Expected a \'.$schema\' field within the parameters file');

          assert(parametersObject.parameters, parametersFilePath + ' - Expected a \'.parameters\' field within the parameters file');
          for (var parameterName in parametersObject.parameters) {
            if (typeof parameterName === 'string') {
              var parameterObject = parametersObject.parameters[parameterName];
              assert(isDefined(parameterObject.value) || isDefined(parameterObject.reference),
                parametersFilePath + ' - Parameter \"' + parameterName + '\" should have a \"value\" or \"reference\" property.');
            }
          }


          var templateFileContents = fs.readFileSync(templateFilePath, { encoding: 'utf-8' }).trim();
          var templateObject = tryParse(templateFilePath, templateFileContents);

          var requestBody = {
            template: templateObject,
            parameters: parametersObject
          };

          var testPromise = RSVP.resolve();

          if (!process.env.VALIDATION_SKIP_VALIDATE) {
            // Calls a remote url which will validate the template and parameters
            if (process.env.TRAVIS_PULL_REQUEST &&
              process.env.TRAVIS_PULL_REQUEST !== 'false') {
              requestBody.pull_request = process.env.TRAVIS_PULL_REQUEST;
            }

            // validate the template paramters, particularly the description field
            assert(templateObject.parameters, 'Expected a \'.parameters\' field within the deployment template');
            for (parameterName in templateObject.parameters) {
              if (typeof parameterName === 'string') {
                assert(templateObject.parameters[parameterName].metadata,
                  templateFilePath + ' - Parameter \"' + parameterName + '\" is missing its \"metadata\" property');
                assert(templateObject.parameters[parameterName].metadata.description,
                  templateFilePath + ' - Parameter \"' + parameterName + '\" is missing its \"description\" field within the metadata property');
              }
            }

            testPromise = testPromise.then(function () {
              console.log("Validating deployment template: " + templateFilePath);
              return new RSVP.Promise(function (resolve, reject) {
                console.log("Validating deployment template (2): " + templateFilePath);
                var validateRequestUrl = process.env.VALIDATION_HOST + "/validate";
                console.log("Request url: \"" + validateRequestUrl + "\"");
                unirest.post(validateRequestUrl)
                  .type('json')
                  .send(JSON.stringify(requestBody))
                  .end(function (response) {
                    console.log("Received response from \"" + validateRequestUrl + "\"");
                    if (response.status !== 200) {
                      console.log("Validation failure for deployment template: " + templateFilePath);
                      return reject(response);
                    }
                    else {
                      console.log("Validation success for deployment template: " + templateFilePath);
                      return resolve(response.body);
                    }
                  });
              });
            });
          }


          // if (!process.env.VALIDATION_SKIP_DEPLOY) {
          //   if (process.env.TRAVIS_PULL_REQUEST &&
          //     process.env.TRAVIS_PULL_REQUEST !== 'false') {
          //     requestBody.pull_request = process.env.TRAVIS_PULL_REQUEST;
          //   }

          //   var intervalObj = timedOutput(true);
          //   debug('making deploy request');

          //   // Calls a remote url which will deploy the template
          //   testPromise = testPromise.then(function (resolve, reject) {
          //     return unirest.post(process.env.VALIDATION_HOST + '/deploy')
          //       .type('json')
          //       .timeout(3600 * 1000) // template deploy can take some time
          //       .send(JSON.stringify(requestBody))
          //       .end(function (response) {
          //         timedOutput(false, intervalObj);
          //         debug(response.status);
          //         debug(response.body);

          //         // 202 is the long poll response
          //         // anything else is really bad
          //         if (response.status !== 202) {
          //           reject(response.body);
          //         }

          //         if (response.body.result === 'Deployment Successful') {
          //           resolve(response.body);
          //         }
          //         else {
          //           reject(response.body);
          //         }
          //       });
          //   });
          // }

          testPromise = testPromise.catch(function (err) {
            var errorString = 'Template Validiation Failed. Try deploying your template with the commands:\n';
            errorString += 'azure group template validate --resource-group (your_group_name) ';
            errorString += ' --template-file ' + templateFilePath + ' --parameters-file ' + parametersFilePath + '\n';
            errorString += 'azure group deployment create --resource-group (your_group_name) ';
            errorString += ' --template-file ' + templateFilePath + ' --parameters-file ' + parametersFilePath;
            assert(false, errorString + ' \n\nServer Error:' + JSON.stringify(err, null, 4));
          });

          return testPromise;
        });
      });
    });
  });
});
