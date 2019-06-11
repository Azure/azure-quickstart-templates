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
var createUiDefFileJSONContent = JSON.stringify(createUiDefFileJSONObject).toLowerCase();
createUiDefFileJSONObject = JSON.parse(createUiDefFileJSONContent);
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

function getErrorMessage(obj, message) {
    return 'json object with \'name\' at line number ' + util.getPosition(obj, createUiDefFile) + ' ' + message;
}


/** Tests for createUiDefinition.json file in a solution template */
describe('createUiDefinition.json file - ', () => {
    //TODO: JSON schema uris are case sensitive, we toLower for simplicity.  If casing is off, it will be caught by the validateJson tests when schema validation is done (future)
    var expectedSchemaVal = 'https://schema.management.azure.com/schemas/0.1.2-preview/createuidefinition.multivm.json#';

    /** A $schema property should be present in the file.
    It's value MUST be  'https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#' */
    it('must have a schema property', () => {
        createUiDefFileJSONObject.should.withMessage('$schema property is expected, and it\'s value must be https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#').have.property('$schema', expectedSchemaVal);
    });

    /** A $handler property should be present in the file.
    It's value MUST be one of the valid handlers */
    it('handler property value should be \'Microsoft.Compute.MultiVm\' or or \'microsoft.azure.createuidef\'', () => {
        createUiDefFileJSONObject.should.withMessage('handler property is expected, and it\'s value should be \'Microsoft.Compute.MultiVm\' or \'microsoft.azure.createuidef\'').have.property('handler', 'microsoft.compute.multivm')
         || 
        createUiDefFileJSONObject.should.withMessage('handler property is expected, and it\'s value should be \'Microsoft.Compute.MultiVm\' or \'microsoft.azure.createuidef\'').have.property('handler', 'microsoft.azure.createuidef');
    });

    /** A $version property should be present in the file.
     The value for $version should match the version in $schema. */
    it('version property value must match schema version', () => {
        assert(typeof(createUiDefFileJSONObject.$schema) !== 'undefined', '$schema property is missing in createUiDefinition.json');
        var createUiDefSchemaVersion = createUiDefFileJSONObject.$schema.match('schema.management.azure.com/schemas/(.*)/createuidefinition')[1]
        createUiDefFileJSONObject.should.have.property('version', createUiDefSchemaVersion);
    });

    /** The file MUST contain 'parameters' and 'outputs' properties. */
    it('must have parameters and outputs properties', () => {
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('outputs');
    });

    /** Each output MUST be present in parameters section of maintemplate.json. */
    var outputsInCreateUiDef = Object.keys(createUiDefFileJSONObject.parameters.outputs);
    it.each(outputsInCreateUiDef, 'output %s must be present in mainTemplate parameters', ['element'], function(element, next) {
        /** if this is a managed app, applicationresourcename will be added by the RP and not in mainTemplate, so skip it */
        if (element != 'applicationresourcename') {
            parametersInTemplate.should.contain(element);
        }
        next();
    });

    /** The parameters MUST have 'basics' and 'steps' properties. */
    it('parameters should have basics and steps properties', () => {
        createUiDefFileJSONObject.parameters.should.have.property('basics');
    });

    /** Get all textbox objects */
    var textboxObjects = util.getObjects(createUiDefFileJSONObject, 'type', 'microsoft.common.textbox');

    /** Each text box control MUST hve a regex constraint, and the value should not be an empty string. */
    it.each(textboxObjects, 'text box control %s must have a regex constraint', ['name'], function(element, next) {
        element.should.have.property('constraints');
        var message = element.name + ' should have regex property on constraints object';
        expect(element.constraints, getErrorMessage(element, message)).to.have.property('regex');
        element.constraints.regex.replace(/\s/g, '').length.should.withMessage('regex value on this text box control should not be an empty string').be.above(0);
        next();
    });

    /** Get all textbox objects */
    var textboxObjects = util.getObjects(createUiDefFileJSONObject, 'type', 'microsoft.common.textbox');

    /** Each text box control MUST hve a validationMessage constraint, and the value should not be an empty string. */
    it.each(textboxObjects, 'text box control %s must have a validationMessage', ['name'], function(element, next) {
        element.should.have.property('constraints');
        var message = element.name + ' should have validationMessage property on constraints object';
        expect(element.constraints, getErrorMessage(element, message)).to.have.property('validationmessage');
        element.constraints.validationmessage.replace(/\s/g, '').length.should.withMessage('validationMessage value on this text box control should not be an empty string').be.above(0);
        next();
    });

    /** A 'location' must be specified in outputs.
    The value should match '[location()]' */
    it('location must be in outputs, and should match [location()]', () => {
        createUiDefFileJSONObject.parameters.outputs.should.withMessage('location property missing in outputs').have.property('location');
        createUiDefFileJSONObject.parameters.outputs.location.should.withMessage('location value should be [location()]').be.eql('[location()]');
    });
});
