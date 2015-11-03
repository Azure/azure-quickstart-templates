var assert = require('assert'),
    fs = require('fs'),
    path = require('path'),
    RSVP = require('rsvp'),
    unirest = require('unirest');

// Vaidates that the expected file paths exist
function ensureExists(templatePath, parametersPath) {
  return fs.existsSync(templatePath) && fs.existsSync(parametersPath);
}

// Calls a remote url which will validate the template and parameters
function validateTemplate(templatePath, parametersPath, validationUrl) {
  var templateData = fs.readFileSync(templatePath, {encoding: 'utf-8'}),
      parameterData = fs.readFileSync(parametersPath, {encoding: 'utf-8'});

  templateData = templateData.trim();
  parameterData = parameterData.trim();

  var requestBody = {
    template: JSON.parse(templateData),
    parameters: JSON.parse(parameterData)
  }

  return new RSVP.Promise(function(resolve, reject) {
    unirest.post(validationUrl)
    .type('json')
    .send(JSON.stringify(requestBody))
    .end(function (response) {

      if (response.status !== 200) {
        return reject(response.body);
      }

      return resolve(response.body);
    });
  });
}

function getDirectories(srcpath) {
  return fs.readdirSync(srcpath).filter(function(file) {
    return fs.statSync(path.join(srcpath, file)).isDirectory();
  });
}
describe('Ensure exists Template', function() {

  var tests = [
    {args: [1, 2],       expected: 3},
    {args: [1, 2, 3],    expected: 6},
    {args: [1, 2, 3, 4], expected: 10}
  ];

  var directories = getDirectories('./');

  directories.forEach(function (dirName) {

    // exceptions
    if (dirName === 'shared_scripts' ||
        dirName === '1' ||
        dirName === '.git') {
      return;
    }
    tests.push({
      args: [path.join(dirName, 'azuredeploy.json'), path.join(dirName, 'azuredeploy.parameters.json') ],
      expected: true
    });
  });


  tests.forEach(function(test) {
    it('Ensure ' + test.args[0] + ' & ' + test.args[1] + ' exist', function() {
      var res = ensureExists.apply(null, test.args);
      assert.equal(res, test.expected);
    });
  });
});

describe('Validate Template Module: ', function() {
  this.timeout(5000);
  var tests = [
    {args: [1, 2],       expected: 3},
    {args: [1, 2, 3],    expected: 6},
    {args: [1, 2, 3, 4], expected: 10}
  ];

  var directories = getDirectories('./');
  var tempCount = 0;
  directories.forEach(function (dirName) {

    tests.push({
      args: [path.join(dirName, 'azuredeploy.json'), path.join(dirName, 'azuredeploy.parameters.json'),
      'http://40.118.211.57.xip.io/validate' ],
      expected: true
    });
  });
  
  tests.forEach(function(test) {
    it('Ensure ' + test.args[0] + ' & ' + test.args[1] + ' is a valid template', function() {
      return validateTemplate.apply(null, test.args)
      .then(function (result) {
        assert.equal(true, true);
      })
      .catch(function (err) {
        throw err;
      });
      
    });
  });
});
