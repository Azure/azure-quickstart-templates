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

var createUiDefFileJSONObject = util.getCreateUiDefFile(folder).jsonObject;
var createUiDefFile = util.getCreateUiDefFile(folder).file;
var mainTemplateFileJSONObject = util.getMainTemplateFile(folder).jsonObject;
var parametersInTemplate = Object.keys(mainTemplateFileJSONObject.parameters);
// convert to lowercase
for (var i in parametersInTemplate) {
    parametersInTemplate[i] = parametersInTemplate[i].toLowerCase();
}

chai.use(function(_chai, _) {
    _chai.Assertion.addMethod('withMessage', function(msg) {
        _.flag(this, 'message', msg);
    });
});

function getErrorMessage(obj) {
    return 'json object with \'name\' at line number ' + util.getPosition(obj, createUiDefFile) + ' is missing the regex property under constraints';
}

describe('createUiDefinition.json file - ', () => {
    var expectedSchemaVal = 'https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#';

    it('must have a schema property', () => {
        createUiDefFileJSONObject.should.withMessage('$schema property is expected, and it\'s value should be ' + expectedSchemaVal).have.property('$schema', expectedSchemaVal);
    });

    it('handler property value should be \'Microsoft.Compute.MultiVm\'', () => {
        createUiDefFileJSONObject.should.withMessage('handler property is expected, and it\'s value should be \'Microsoft.Compute.MultiVm\'').have.property('handler', 'Microsoft.Compute.MultiVm');
    });

    it('version property value must match schema version', () => {
        assert(typeof(createUiDefFileJSONObject.$schema) !== 'undefined', '$schema property is missing in createUiDefinition.json');
        var createUiDefSchemaVersion = createUiDefFileJSONObject.$schema.match('schema.management.azure.com/schemas/(.*)/CreateUIDefinition')[1]
        createUiDefFileJSONObject.should.have.property('version', createUiDefSchemaVersion);
    });

    it('must have parameters and outputs properties', () => {
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('outputs');
    });

    var outputsInCreateUiDef = Object.keys(createUiDefFileJSONObject.parameters.outputs);
    it.each(outputsInCreateUiDef, 'output %s must be present in mainTemplate parameters', ['element'], function(element, next) {
        parametersInTemplate.should.contain(element.toLowerCase());
        next();
    });

    it('parameters should have basics and steps properties', () => {
        createUiDefFileJSONObject.parameters.should.have.property('basics');
        createUiDefFileJSONObject.parameters.should.have.property('steps');
    });

    // get text box controls in basics
    var basicsTextBox = Object.keys(createUiDefFileJSONObject.parameters.basics).map(function(key) {
        return createUiDefFileJSONObject.parameters.basics[key];
    }).filter(function(obj) {
        if (obj.type) {
            return obj.type.toLowerCase() == 'microsoft.common.textbox';
        }
    });

    // get text box controls in steps
    var steps = Object.keys(createUiDefFileJSONObject.parameters.steps).map(function(key) {
        return createUiDefFileJSONObject.parameters.steps[key];
    });
    var stepsTextBox = [];
    steps.forEach(step => {
        if (step.elements) {
            step.elements.forEach(element => {
                if (element.type) {
                    if (element.type.toLowerCase() == 'microsoft.common.textbox') {
                        stepsTextBox.push(element);
                    }
                }
            });
        }
    });

    it.each(basicsTextBox.concat(stepsTextBox), 'text box control %s must have a regex constraint', ['name'], function(element, next) {
        element.should.have.property('constraints');
        expect(element.constraints, getErrorMessage(element)).to.have.property('regex');
        next();
    });

    it('location must be in outputs, and should match [location()]', () => {
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('outputs');
        createUiDefFileJSONObject.parameters.outputs.should.withMessage('location property missing in outputs').have.property('location');
        createUiDefFileJSONObject.parameters.outputs.location.toLowerCase().should.withMessage('location value should be [location()]').be.eql('[location()]');
    });
});