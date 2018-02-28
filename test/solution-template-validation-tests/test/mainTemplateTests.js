var assert = require('assert');
var util = require('./util');
const filesFolder = './';
var path = require('path');
var chai = require('chai');
var assert = chai.assert; // Using Assert style
var expect = chai.expect; // Using Expect style
var should = chai.should(); // Using Should style

require('it-each')({ testPerIteration: true });

var folder = process.env.npm_config_folder || filesFolder;
var mainTemplateFileJSONObject = util.getMainTemplateFile(folder).jsonObject;
var mainTemplateFile = util.getMainTemplateFile(folder).file;
var createUiDefFileJSONObject = util.getCreateUiDefFile(folder).jsonObject;
var createUiDefFile = util.getCreateUiDefFile(folder).file;
var templateFiles = util.getTemplateFiles(folder).files;
var templateFileJSONObjects = util.getTemplateFiles(folder).fileJSONObjects;

chai.use(function(_chai, _) {
    _chai.Assertion.addMethod('withMessage', function(msg) {
        _.flag(this, 'message', msg);
    });
});

function getErrorMessage(obj, file, message) {
    return 'json object with \'name\' at line number ' + util.getPosition(obj, file) + ' ' + message;
}

/** Tests for template files in a solution template */
describe('template files - ', () => {

    /** Tests for parameters in template files */
    describe('parameters tests - ', () => {

        /** maintemplate.json should have a parameters property */
        it('maintemplate.json should have a "parameters" property', () => {
            mainTemplateFileJSONObject.should.have.property('parameters');
        });

        var parametersInMainTemplate = Object.keys(mainTemplateFileJSONObject.parameters);

        /** Each parameter that does not have a defaultValue MUST have a corresponding output in createUiDefinition.json */
        it('each parameter that does not have a defaultValue, must have a corresponding output in createUIDef', () => {
            var currentDir = path.dirname(mainTemplateFile);
            // assert create ui def exists in the above directory
            util.assertCreateUiDefExists(currentDir);

            // get the corresponding create ui def
            var createUiDefJSONObject = util.getCreateUiDefFile(currentDir).jsonObject;

            // get output keys in main template
            var outputsInCreateUiDef = Object.keys(createUiDefJSONObject.parameters.outputs);

            // convert to lowercase
            for (var i in outputsInCreateUiDef) {
                outputsInCreateUiDef[i] = outputsInCreateUiDef[i].toLowerCase();
            }

            // validate each parameter in main template has a value in outputs
            parametersInMainTemplate.forEach(parameter => {
                if (typeof(mainTemplateFileJSONObject.parameters[parameter].defaultValue) === 'undefined') {
                    outputsInCreateUiDef.should.withMessage('in file:mainTemplate.json. outputs in createUiDefinition is missing the parameter ' + parameter).contain(parameter.toLowerCase());
                }
            });
        });

        /** If securestring, the default value (if it exists) should be null*/
        it('non-null default values must not be provided for secureStrings', () => {
            templateFileJSONObjects.forEach(templateJSONObject => {
                var templateObject = templateJSONObject.value;
                Object.keys(templateObject.parameters).forEach(parameter => {
                    if (templateObject.parameters[parameter].type.toLowerCase() == 'securestring') {
                        // get default value if one exists
                        var defaultVal = templateObject.parameters[parameter].defaultValue;
                        if (defaultVal && defaultVal.length > 0) {
                            expect(templateObject.parameters[parameter], 'in file:' + templateJSONObject.filename + parameter + ' should not have defaultValue').to.not.have.property('defaultValue');
                        }
                    }
                });
            });

        });

        // Not required pending Jianping's PR
        it('a parameter named "location" must exist and must be used on all resource "location" properties', () => {
            mainTemplateFileJSONObject.should.withMessage('file:mainTemplate.json is missing parameters property').have.property('parameters');
            mainTemplateFileJSONObject.parameters.should.withMessage('file:mainTemplate.json is missing location property in parameters').have.property('location');

            // TODO: if location default value exists, it should be set to resourceGroup.location(). Correct?

            // each resource location should be "location": "[parameters('location')]"
            var expectedLocation = '[parameters(\'location\')]';
            var message = 'in file:mainTemplate.json should have location set to [parameters(\'location\')]';
            Object.keys(mainTemplateFileJSONObject.resources).forEach(resource => {
                var val = mainTemplateFileJSONObject.resources[resource];
                if (val.location && val.type.toLowerCase() != 'microsoft.resources/deployments') {
                    val.location.split(' ').join('').should.withMessage(getErrorMessage(val, mainTemplateFile, message)).be.eql(expectedLocation);
                }
            });
        });

        var mainTemplateFileContent = JSON.stringify(mainTemplateFileJSONObject).toLowerCase();
        it.each(parametersInMainTemplate, 'parameter %s must be used in maintemplate', ['element'], function(element, next) {
            var paramString = 'parameters(\'' + element.toLowerCase() + '\')';
            assert(mainTemplateFileContent.includes(paramString) === true, 'unused parameter ' + element + ' in file mainTemplate.json');
            next();
        });
    });

    describe('resources tests - ', () => {
        // Not required pending Jianping's PR
        it('resourceGroup().location must not be used in the solution template except as a defaultValue for the location parameter', () => {
            templateFileJSONObjects.forEach(templateJSONObject => {
                var templateObject = templateJSONObject.value;
                templateObject.should.have.property('resources');
                var locationString = '[resourceGroup().location]';
                var message = 'in file:' + templateJSONObject.filename + ' should NOT have location set to [resourceGroup().location]';
                Object.keys(templateObject.resources).forEach(resource => {
                    var val = templateObject.resources[resource];
                    if (val.location) {
                        val.location.should.withMessage(getErrorMessage(val, templateJSONObject.filepath, message)).not.be.eql(locationString);
                    }
                });
            });
        });

        it('apiVersions must NOT be retrieved using providers().apiVersions[n].  This function is non-deterministic', () => {
            templateFileJSONObjects.forEach(templateJSONObject => {
                var templateObject = templateJSONObject.value;
                templateObject.should.have.property('resources');
                var message = 'in file:' + templateJSONObject.filename + ' should NOT have api version determined by providers().';
                Object.keys(templateObject.resources).forEach(resource => {
                    var val = templateObject.resources[resource];
                    if (val.apiVersion) {
                        val.apiVersion.should.withMessage(getErrorMessage(val, templateJSONObject.filepath, message)).not.contain('providers(');
                    }
                });
            });
        });
    });
});