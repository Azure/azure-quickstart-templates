/*global describe, it*/
var assert = require('assert'),
  fs = require('fs'),
  execSync = require('child_process').execSync,
  path = require('path'),
  RSVP = require('rsvp'),
  unirest = require('unirest'),
  skeemas = require('skeemas'),
  debug = require('debug')('validator'),
  parallel = require('mocha.parallel'),
  colors = require('mocha/lib/reporters/base').colors;

// setup mocha color scheme
// 32 = console code for green
colors.pass = 32;

function getModifiedPaths() {
  assert.ok(process.env.TRAVIS_COMMIT_RANGE, 'VALIDATE_MODIFIED_ONLY requires TRAVIS_COMMIT_RANGE to be set to [START_COMMIT_HASH]...[END_COMMIT_HASH]');
  var stdout = execSync('git diff --name-only ' + process.env.TRAVIS_COMMIT_RANGE, {
    encoding: 'utf8'
  });
  var lines = stdout.split('\n');
  var result = {};

  for (var i = 0; i < lines.length; i += 1) {
    result[lines[i]] = lines[i];
  }

  return result;
}
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

// Vaidates that the expected file paths exist
function ensureExists(templatePath) {
  assert(fs.existsSync(templatePath), 'The file ' + templatePath + ' is missing.');
}

function validateMetadata(metadataPath) {
  var metadataData = fs.readFileSync(metadataPath, {
    encoding: 'utf-8'
  });
  metadataData = metadataData.trim();

  var metadata = tryParse(metadataPath, metadataData);

  var result = skeemas.validate(metadata, {
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
      }
    },
    additionalProperties: false
  });
  var messages = '';
  result.errors.forEach(function (error) {
    messages += (metadataPath + ' - ' + error.context + ':' + error.message + '\n');
  });
  assert(result.valid, messages);

  // validate description has no html
  assert(!/<[a-z][\s\S]*>/i.test(metadata.description), metadataPath + ' - Contains possible HTML elements which are not allowed');
  // validate date
  var date = new Date(metadata.dateUpdated);
  var currentTime = new Date(Date.now());
  assert(!isNaN(date.getTime()), metadataPath + ' - dateUpdated field should be a valid date in the format YYYY-MM-DD');
  // validate date is not in future
  assert(date < currentTime, metadataPath + ' - dateUpdated field should not be in the future');
}

// azure cli apparently does not check for this
function validateTemplateParameters(templatePath, templateObject) {
  assert.ok(templateObject.parameters, 'Expected a \'.parameters\' field within the deployment template');
  for (var k in templateObject.parameters) {
    if (typeof k === 'string') {
      assert.ok(templateObject.parameters[k].metadata,
        templatePath + ' -  Parameter \"' + k + '\" is missing its \"metadata\" property');
      assert.ok(templateObject.parameters[k].metadata.description,
        templatePath + ' - Parameter \"' + k + '\" is missing its \"description\" field within the metadata property');
    }
  }
}

function validateParamtersFile(parametersPath) {
  var parametersData = fs.readFileSync(parametersPath, {
    encoding: 'utf-8'
  });
  var metadataData = parametersData.trim();

  var parametersObject = tryParse(parametersPath, metadataData);

  assert.ok(parametersObject.parameters, parametersPath + ' - Expected a \'.parameters\' field within the parameters file');
  for (var k in parametersObject.parameters) {
    if (typeof k === 'string') {
      assert.ok(parametersObject.parameters[k].value !== null &&
        parametersObject.parameters[k].value !== undefined &&
        parametersObject.parameters[k].value !== '',
        parametersPath + ' -  Parameter \"' + k + '\" is missing its value field');
    }
  }
}

function prepTemplate(templatePath, parametersPath) {
  var templateData = fs.readFileSync(templatePath, {
      encoding: 'utf-8'
    }),
    parameterData = fs.readFileSync(parametersPath, {
      encoding: 'utf-8'
    });

  templateData = templateData.trim();
  parameterData = parameterData.trim();

  var requestBody = {
    template: tryParse(templatePath, templateData),
    parameters: tryParse(templatePath, parameterData)
  };

  return requestBody;
}

// Calls a remote url which will validate the template and parameters
function validateTemplate(templatePath, parametersPath) {
  var requestBody = prepTemplate(templatePath, parametersPath);

  // validate the template paramters, particularly the description field
  validateTemplateParameters(templatePath, requestBody.template);

  return new RSVP.Promise(function (resolve, reject) {
    unirest.post(process.env.VALIDATION_HOST + '/validate')
      .type('json')
      .send(JSON.stringify(requestBody))
      .end(function (response) {
        if (response.status !== 200) {
          return reject(response);
        }

        return resolve(response.body);
      });
  });
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

// Calls a remote url which will deploy the template
function deployTemplate(templatePath, parametersPath) {
  var requestBody = prepTemplate(templatePath, parametersPath);

  if (process.env.TRAVIS_PULL_REQUEST &&
    process.env.TRAVIS_PULL_REQUEST !== 'false') {
    requestBody.pull_request = process.env.TRAVIS_PULL_REQUEST;
  }

  // validate the template paramters, particularly the description field
  validateTemplateParameters(templatePath, requestBody.template);

  var intervalObj = timedOutput(true);
  debug('making deploy request');

  return new RSVP.Promise(function (resolve, reject) {
    unirest.post(process.env.VALIDATION_HOST + '/deploy')
      .type('json')
      .timeout(3600 * 1000) // template deploy can take some time
      .send(JSON.stringify(requestBody))
      .end(function (response) {
        timedOutput(false, intervalObj);
        debug(response.status);
        debug(response.body);

        // 202 is the long poll response
        // anything else is really bad
        if (response.status !== 202) {
          return reject(response.body);
        }

        if (response.body.result === 'Deployment Successful') {
          return resolve(response.body);
        } else {
          return reject(response.body);
        }
      });
  });
}

function getDirectories(srcpath) {
  return fs.readdirSync(srcpath).filter(function (file) {
    return fs.statSync(path.join(srcpath, file)).isDirectory();
  });
}

// Generates the mocha tests based on directories in
// the existing repo.
function generateTests(modifiedPaths) {
  var tests = [];
  var directories = getDirectories('./');
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

  return tests;
}

// Group tests in chunks defined by an environment variable
// or by the default value
function groupTests(modifiedPaths) {
  // we probably shouldn't deploy a ton of templates at once...
  var tests = generateTests(modifiedPaths),
    testGroups = [],
    groupIndex = 0,
    counter = 0,
    groupSize = process.env.PARALLEL_DEPLOYMENT_NUMBER || 2;

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

  return testGroups;
}

describe('Template', function () {
  this.timeout(7100 * 1000);

  var modifiedPaths;

  if (process.env.VALIDATE_MODIFIED_ONLY) {
    var count = 0;
    // we automatically reset to the beginning of the commit range
    // so this includes all file paths that have changed for the CI run
    modifiedPaths = getModifiedPaths();
    debug(modifiedPaths);
    for (var i in modifiedPaths) {
      if (typeof i === 'string') {
        count += 1;
      }
    }

    assert(count !== 0, 'No changes were detected in your commit. Verify you added files and try again.');
  }

  var testGroups = groupTests(modifiedPaths);

  testGroups.forEach(function (tests) {
    parallel('Running ' + tests.length + ' Parallel Template Validation(s)...', function () {
      tests.forEach(function (test) {
        it(test.args[0] + ' & ' + test.args[1] + ' should be valid', function () {
          // validate template files are in correct place
          test.args.forEach(function (path) {
            ensureExists.apply(null, [path]);
          });

          validateMetadata.apply(null, [test.args[2]]);
          validateParamtersFile.apply(null, [test.args[1]]);

          return validateTemplate.apply(null, test.args)
            .then(function () {
              debug('template validation sucessful, deploying template...');
              return deployTemplate.apply(null, test.args);
            })
            .then(function () {
              // success
              return assert(true);
            })
            .catch(function (err) {
              var errorString = 'Template Validiation Failed. Try deploying your template with the commands:\n';
              errorString += 'azure group template validate --resource-group (your_group_name) ';
              errorString += ' --template-file ' + test.args[0] + ' --parameters-file ' + test.args[1] + '\n';
              errorString += 'azure group deployment create --resource-group (your_group_name) ';
              errorString += ' --template-file ' + test.args[0] + ' --parameters-file ' + test.args[1];
              assert(false, errorString + ' \n\nServer Error:' + JSON.stringify(err, null, 4));
            });
        });
      });
    });
  });
});
