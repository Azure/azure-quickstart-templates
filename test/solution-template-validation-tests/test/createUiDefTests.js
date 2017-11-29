var assert = require('assert');
var util = require('./util');
const filesFolder = './';
var path = require('path');
var chai = require('chai');
var assert = chai.assert; // Using Assert style
var expect = chai.expect; // Using Expect style
var should = chai.should(); // Using Should style

var folder = process.env.npm_config_folder || filesFolder;

var createUiDefFileJSONObject = util.getCreateUiDefFile(folder).jsonObject;
var createUiDefFile = util.getCreateUiDefFile(folder).file;

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

    it('each property in the outputs object must have a corresponding parameter in main template', () => {
        var currentDir = path.dirname(createUiDefFile);
        // assert main template exists in the above directory
        util.assertMainTemplateExists(currentDir);

        // get the corresponding main template
        var mainTemplateJSONObject = util.getMainTemplateFile(currentDir).jsonObject;

        // get parameter keys in main template
        var parametersInTemplate = Object.keys(mainTemplateJSONObject.parameters);

        // convert to lowercase
        for (var i in parametersInTemplate) {
            parametersInTemplate[i] = parametersInTemplate[i].toLowerCase();
        }

        // validate each output in create ui def has a value in parameters
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('outputs');
        var outputsInCreateUiDef = Object.keys(createUiDefFileJSONObject.parameters.outputs);
        outputsInCreateUiDef.forEach(output => {
            parametersInTemplate.should.contain(output.toLowerCase());
        });
    });

    it('all text box controls must have a regex constraint', () => {
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('basics');
        createUiDefFileJSONObject.parameters.should.have.property('steps');

        Object.keys(createUiDefFileJSONObject.parameters.basics).forEach(obj => {
            var val = createUiDefFileJSONObject.parameters.basics[obj];
            val.should.have.property('type');
            if (val.type.toLowerCase() == 'microsoft.common.textbox') {
                val.should.have.property('constraints');
                expect(val.constraints, getErrorMessage(val)).to.have.property('regex');
            }
        });

        // TODO revisit why certain steps elements return undefined
        var steps = Array.from(Object.keys(createUiDefFileJSONObject.parameters.steps));
        for (count = 0; count < steps.length; count++) {
            var val = createUiDefFileJSONObject.parameters.steps[count];
            val.should.have.property('elements');
            var elements = Array.from(Object.keys(val.elements));
            for (count1 = 0; count1 < elements.length; count1++) {
                var elementVal = val.elements[count1];
                if (elementVal.type.toLowerCase() == 'microsoft.common.textbox') {
                    elementVal.should.have.property('constraints');
                    expect(elementVal.constraints, getErrorMessage(elementVal)).to.have.property('regex');
                }
            }
        }
    });

    it('location must be in outputs, and should match [location()]', () => {
        createUiDefFileJSONObject.should.have.property('parameters');
        createUiDefFileJSONObject.parameters.should.have.property('outputs');
        createUiDefFileJSONObject.parameters.outputs.should.withMessage('location property missing in outputs').have.property('location');
        createUiDefFileJSONObject.parameters.outputs.location.toLowerCase().should.withMessage('location value should be [location()]').be.eql('[location()]');
    });
});