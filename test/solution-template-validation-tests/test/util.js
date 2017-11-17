var fs = require('fs');
var lineColumn = require("line-column");
var path = require('path');
var chai = require('chai');
var assert = chai.assert; // Using Assert style
var expect = chai.expect; // Using Expect style
var should = chai.should(); // Using Should style
var _this = this;

var createUiDefFileName = "createuidefinition.json";
var mainTemplateFileName = "maintemplate.json";

function getFiles(folder, fileType) {
    if (folder == './') {
        folder = __dirname + '/../';
    }
    if (fileType) {
        return fs.readdirSync(folder).filter(function(file) {
            return file.toLowerCase().indexOf(fileType) !== -1;
        });
    } else {
        return fs.readdirSync(folder);
    }
}

// Get create ui def file
exports.getCreateUiDefFile = function getCreateUiDefFile(folder) {
    var createUiDefFiles = getFiles(folder, createUiDefFileName);
    createUiDefFiles.length.should.equals(1, 'Only one createUiDefinition.json file should exist, but found ' + createUiDefFiles.length + ' file(s) in path ' + folder);
    var fileString = fs.readFileSync(path.resolve(folder, createUiDefFiles[0]), {
        encoding: 'utf8'
    }).trim();
    return {
        file: path.resolve(folder, createUiDefFiles[0]),
        jsonObject: JSON.parse(fileString)
    };
};

// Get main template file
exports.getMainTemplateFile = function getMainTemplateFile(folder) {
    var mainTemplateFiles = getFiles(folder, mainTemplateFileName);
    mainTemplateFiles.length.should.equals(1, 'Only one mainTemplate.json file should exist, but found ' + mainTemplateFiles.length + ' file(s)');
    var fileString = fs.readFileSync(path.resolve(folder, mainTemplateFiles[0]), {
        encoding: 'utf8'
    }).trim();
    return {
        file: path.resolve(folder, mainTemplateFiles[0]),
        jsonObject: JSON.parse(fileString)
    };
};

// Get template files
exports.getTemplateFiles = function getTemplateFiles(folder) {
    var templateFiles = getFiles(folder, '.json');
    var files = [];
    var fileJSONObjects = [];
    templateFiles.forEach(f => {
        if (f.toLowerCase().indexOf(createUiDefFileName) == -1) {
            var fileString = fs.readFileSync(path.resolve(folder, f), {
                encoding: 'utf8'
            }).trim();
            var jsonObject = JSON.parse(fileString);
            if (jsonObject.$schema && jsonObject.$schema.match('schema.management.azure.com/schemas/(.*)/deploymentTemplate.json')) {
                files.push(path.resolve(folder, f));
                fileJSONObjects.push({
                    filename: f,
                    value: jsonObject,
                    filepath: path.resolve(folder, f)
                });
            }
        }
    });
    return {
        files: files,
        fileJSONObjects: fileJSONObjects
    };
};

// verify directory contains the file
exports.assertMainTemplateExists = function assertMainTemplateExists(folder) {
    _this.getMainTemplateFile(folder);
};

// verify directory contains the file
exports.assertCreateUiDefExists = function assertCreateUiDefExists(folder) {
    _this.getCreateUiDefFile(folder);
};

// for now, get position of name element in file, so better error message can be thrown
exports.getPosition = function getPosition(obj, file) {
    var fileString = fs.readFileSync(file, {
        encoding: 'utf8'
    }).trim();

    // get the object "name"
    var stringToSearch;
    for (var key in obj) {
        if (key.toLowerCase() == 'name') {
            stringToSearch = '"name": "' + obj[key] + '"';
        }
    }
    var ind = fileString.indexOf(stringToSearch);
    var lc = lineColumn(fileString).fromIndex(ind);
    if (lc) {
        return lc.line
    }
    return 'UNIDENTIFIED';
};