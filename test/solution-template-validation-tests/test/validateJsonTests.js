require('it-each')({ testPerIteration: true });

var fs = require('fs');
var util = require('./util');
const filesFolder = './';
var path = require('path');
var chai = require('chai');
var jsonlint = require('jsonlint');
var should = chai.should();

var folder = process.env.npm_config_folder || filesFolder;

var jsonFiles = util.getFiles(folder, '.json');

/** Validates all json files in the given folder are valid. */
describe('json files in folder - ', () => {
    // TODO: test ALL json files in subfolders are also returned here
    it.each(jsonFiles, '%s must be a valid json', ['element'], function(element, next) {
        var fileString = fs.readFileSync(path.resolve(folder, element), {
            encoding: 'utf8'
        }).trim();
        try {
            jsonlint.parse(fileString);
        } catch (e) {
            should.fail(null, null, element + ' is not a valid json. ' + e);
        }
        next();
    });
});