var fs = require('fs');
var lineColumn = require("line-column");
var path = require('path');
var chai = require('chai');
var should = chai.should();
var _this = this;

var createUiDefFileName = "createuidefinition.json";
var mainTemplateFileName = "maintemplate.json";

// Get files in the root folder and in the nested folder if recursive is set true, otherwise only get files in the root folder
exports.getFiles = function getFiles(folder, fileType, filelist, recursive) {
    if (folder == './') {
        folder = __dirname + '/../';
    }
    var files = fs.readdirSync(folder);
    filelist = filelist || [];
    files.forEach(function(file) {
        if (fs.statSync(path.join(folder, file)).isDirectory() && recursive) {
            filelist = getFiles(path.join(folder, file), fileType, filelist, recursive);
        } else {
            if (file.toLowerCase().endsWith(fileType)) {
                filelist.push(path.join(folder, file));
            }
        }
    });
    return filelist;
};

// Get create ui def file
exports.getCreateUiDefFile = function getCreateUiDefFile(folder) {
    var createUiDefFiles = [];
    createUiDefFiles = _this.getFiles(folder, createUiDefFileName, createUiDefFiles, true);
    createUiDefFiles.length.should.equals(1, 'Only one createUiDefinition.json file should exist, but found ' + createUiDefFiles.length + ' file(s) in path ' + folder);
    var fileString = fs.readFileSync(path.resolve(createUiDefFiles[0]), {
        encoding: 'utf8'
    }).trim();
    return {
        file: path.resolve(createUiDefFiles[0]),
        jsonObject: JSON.parse(fileString)
    };
};

// Get main template file
exports.getMainTemplateFile = function getMainTemplateFile(folder) {
    var mainTemplateFiles = [];
    mainTemplateFiles = _this.getFiles(folder, mainTemplateFileName, mainTemplateFiles, true);
    var rootMainTemplateFiles = [];
    rootMainTemplateFiles = _this.getFiles(folder, mainTemplateFileName, rootMainTemplateFiles, false);
    /** There must be one mainTemplate.json in the root folder. */
    rootMainTemplateFiles.length.should.equals(1, 'Only one mainTemplate.json file should exist in the root folder, but found ' + mainTemplateFiles.length + ' file(s)');
    /** There cannot be more than one mainTemplate.json in the root folder and nested folders. */
    mainTemplateFiles.length.should.equals(1, 'Only one mainTemplate.json file should exist, but found ' + mainTemplateFiles.length + ' file(s) in path ' + path.resolve(folder));
    var fileString = fs.readFileSync(path.resolve(mainTemplateFiles[0]), {
        encoding: 'utf8'
    }).trim();
    return {
        file: path.resolve(mainTemplateFiles[0]),
        jsonObject: JSON.parse(fileString)
    };
};

// Get objects that matches a given key and value
exports.getObjects = function getObjects(obj, key, val) {
    var objects = [];
    for (var i in obj) {
        if (!obj.hasOwnProperty(i)) continue;
        if (typeof obj[i] == 'object') {
            objects = objects.concat(getObjects(obj[i], key, val));
        } else
        if (i.toLowerCase() == key && obj[i].toLowerCase() == val) { //
            objects.push(obj);
        }
    }
    return objects;
};

// Get template files
exports.getTemplateFiles = function getTemplateFiles(folder) {
    var templateFiles = [];
    templateFiles = _this.getFiles(folder, '.json', templateFiles, true);
    var files = [];
    var fileJSONObjects = [];
    templateFiles.forEach(f => {
        if (f.toLowerCase().indexOf(createUiDefFileName) == -1) {
            var fileString = fs.readFileSync(path.resolve(f), {
                encoding: 'utf8'
            }).trim();
            var jsonObject = JSON.parse(fileString);
            if (jsonObject.$schema && jsonObject.$schema.match('schema.management.azure.com/schemas/(.*)/deploymentTemplate.json')) {
                files.push(path.resolve(f));
                fileJSONObjects.push({
                    filename: f,
                    value: jsonObject,
                    filepath: path.resolve(f)
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