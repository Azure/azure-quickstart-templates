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
var mainTemplateFileName = "maintemplate.json";
var createUiDefFileJSONObject = util.getCreateUiDefFile(folder).jsonObject;
var createUiDefFile = util.getCreateUiDefFile(folder).file;
var templateFiles = util.getTemplateFiles(folder).files;
var templateFileJSONObjects = util.getTemplateFiles(folder).fileJSONObjects;

console.log('Testing template files...');
templateFiles.forEach(function (file) {
    console.log(file);
});

chai.use(function (_chai, _) {
    _chai.Assertion.addMethod('withMessage', function (msg) {
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

        var mainTemplateFileContent = JSON.stringify(mainTemplateFileJSONObject).toLowerCase();

        mainTemplateFileJSONObject = JSON.parse(mainTemplateFileContent);

        /** maintemplate.json should have a parameters property */
        it('maintemplate.json should have a "parameters" property', () => {
            mainTemplateFileJSONObject.should.have.property('parameters');
        });

        var currentDir = path.dirname(mainTemplateFile);
        // assert create ui def exists in the above directory
        util.assertCreateUiDefExists(currentDir);

        // get the corresponding create ui def
        var createUiDefJSONObject = util.getCreateUiDefFile(currentDir).jsonObject;

        var createUiDefJSONStr = JSON.stringify(createUiDefJSONObject).toLowerCase();

        createUiDefJSONObject = JSON.parse(createUiDefJSONStr);

        // get output keys in main template
        var outputsInCreateUiDef = Object.keys(createUiDefJSONObject.parameters.outputs);

        var parametersInMainTemplate = Object.keys(mainTemplateFileJSONObject.parameters);
        /** Validate each parameter that does not have a defaultValue in mainTemplate, has a value in outputs */
        it.each(parametersInMainTemplate, 'parameter %s that does not have a defaultValue in file mainTemplate.json, must have a corresponding output in createUiDefinition.json', ['element'], function(element, next){
            if (typeof(mainTemplateFileJSONObject.parameters[element].defaultvalue) === 'undefined') {
                outputsInCreateUiDef.should.withMessage('in file:mainTemplate.json, outputs in createUiDefinition is missing the parameter ' + element).contain(element);
            }
            next();
        });

        /** If securestring, the default value (if it exists) should be null*/
        it('non-null default values must not be provided for secureStrings', () => {
            templateFileJSONObjects.forEach(templateJSONObject => {
                var templateObject = templateJSONObject.value;
                Object.keys(templateObject.parameters).forEach(parameter => {
                    if (templateObject.parameters[parameter].type == 'securestring') {
                        // get default value if one exists
                        var defaultval = templateObject.parameters[parameter].defaultvalue;
                        if (defaultval && defaultval.length > 0) {
                            expect(templateObject.parameters[parameter], 'in file:' + templateJSONObject.filename + ' "' + parameter + '" should not have defaultValue').to.not.have.property('defaultvalue');
                        }
                    }
                });
            });

        });

        /** The location parameter MUST NOT have allowedValues property and if it has defaultValue property, it's value MUST be '[resourceGroup().location]' */
        it('a parameter named "location" must exist and it must have a defaultValue of resourceGroup().location', () => {
            mainTemplateFileJSONObject.should.withMessage('file:mainTemplate.json is missing parameters property').have.property('parameters');
            mainTemplateFileJSONObject.parameters.should.withMessage('file:mainTemplate.json is missing location property in parameters').have.property('location');

            /** The location parameter can have a defaultValue property, and its value must be '[resourceGroup().location]' */
            var location = mainTemplateFileJSONObject.parameters.location;
            if (location.defaultvalue) {
                location.defaultvalue.should.withMessage('in file:mainTemplate.json, the default value of location property MUST be [resourceGroup().location]').be.eql('[resourcegroup().location]');
            }
            location.should.withMessage('in file:mainTemplate.json, location property MUST NOT have allowedValues property').not.have.property('allowedvalues');
        });

        /** Validate each parameter should be used in main template */
        it.each(parametersInMainTemplate, 'parameter %s must be used in file mainTemplate.json', ['element'], function(element, next) {
            var paramString = 'parameters(\'' + element + '\')';
            assert(mainTemplateFileContent.includes(paramString) === true, 'unused parameter "' + element + '" in file mainTemplate.json');
            next();
        });
    });

    describe('resources tests - ', () => {
        templateFileJSONObjects.forEach(templateJSONObject => {
            var templateObject = templateJSONObject.value;
            templateObject.should.have.property('resources');
            var resources = Object.keys(templateObject.resources).map(function (key) {
                return templateObject.resources[key];
            });
            /** Each resource location should be an expression "location": "[*]" or "global" */
            it.each(resources, 'location value of resource %s should be an expression or "global"', ['name'], function (element, next) {
                var message = 'in file:' + templateJSONObject.filename + ' should have location set to an expression';
                if (element.location) {
                    element.location.should.withMessage(getErrorMessage(element, templateJSONObject.filepath, message)).match(/\[.+\]|global/);
                }
                next();
            });
            /** resourceGroup().location should NOT be present anywhere in template, EXCEPT as a defaultValue */
            it.each(templateObject, 'resourceGroup().location must NOT be be used in the template file ' + templateJSONObject.filename + '.', function (element, next) {
                var templateFileContent = JSON.stringify(templateObject).toLowerCase();

                // if this is mainTemplate.json, a defaultValue of resourceGroup().location is OK, so remove it before searching for it
                if (templateJSONObject.filename.toLowerCase() == (folder + '\\maintemplate.json')) {
                    templateFileContent = templateFileContent.replace(/\"defaultvalue\":\s*\"\[resourcegroup\(\)\.location\]\"/, "");
                }

                var locationString = 'resourcegroup().location';
                var message = 'in file:' + templateJSONObject.filename + ' should NOT have location set to resourceGroup().location';
                assert(templateFileContent.includes(locationString) === false, message);
                next();
            });
            /** providers().apiVersions[n] must not be present for all template files. */

            it.each(templateObject, 'apiVersions must NOT be retrieved using providers().apiVersions[n] in the template file ' + templateJSONObject.filename + '. This function is non-deterministic.', function (element, next) {
                var templateFileContent = JSON.stringify(templateObject).toLowerCase();
                var message = 'in file:' + templateJSONObject.filename + ' should NOT have api version determined by providers().';
                assert(templateFileContent.match(/providers\(.*?\)\.apiversions/) === null, message);
                next();

            });
            /** VM Image ref should not contain preview */
            // NOTE: Property names are case sensitive in the test though they are not in ARM - the test will fail if different casing is used in the template

            /** TODO: need to account for use of variables and parameters in the property value
                If the value is a simple variable we can resolve easily
                If the value is a parameter, get the defaultValue 
                Note that the variable may be at the imageReference level, not the offer level... that's why we're currently checking
                templateObject.resources[resource].properties.storageProfile.imageReference.toLowerCase();
                instead of
                templateObject.resources[resource].properties.storageProfile.imageReference.offer.toLowerCase();
            */
                
            it('VM Image ref must not contain "-preview"', () => {
                var templateObject = templateJSONObject.value;
                Object.keys(templateObject.resources).forEach(resource => {
                    var resourceType = templateObject.resources[resource].type.toLowerCase();
                    if (resourceType === 'microsoft.compute/virtualmachines') {
                        console.log('VM');
                        var previewString = "-preview";
                        var offer = JSON.stringify(templateObject.resources[resource].properties.storageprofile.imagereference).toLowerCase();
                        var message = 'in file:' + templateJSONObject.filename + ' VM must NOT use a preview image: ' + offer;
                        assert(offer.includes(previewString) === false, message);
                    }
                    if (resourceType === 'microsoft.compute/virtualmachinescalesets') {
                        console.log('VMSS');
                        var previewString = "-preview";
                        var offer = JSON.stringify(templateObject.resources[resource].properties.virtualmachineprofile.storageprofile.imagereference).toLowerCase();
                        var message = 'in file:' + templateJSONObject.filename + ' VMSS must NOT use a preview image: ' + offer;
                        assert(offer.includes(previewString) === false, message);
                    }
                });
            });
        });
    });
});
