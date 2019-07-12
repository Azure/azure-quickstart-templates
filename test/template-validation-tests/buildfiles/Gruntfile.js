"use strict";
//===============================================================================
var version = '2017.03.13B'; // - selliott
//==
//== Validate:
//==    * CreateUIDefinition against schema
//==    * ARM Templates as valid JSON files
//==
//== Notes:
//==    1. Assumes all JSON files are to be validated.
//==    2. Subdirectories in the source tree are included in the validation.  i.e.,
//==       JSON files from subdirectories are stripped and placed in the same 
//==       directory structure under ${stripSubFolder}.
//==    3. The source JSON files are stripped of Javascript comments and 
//==       emitted to the ${stripSubFolder} subdirectory tree.  These files
//==       (under ${stripSubFolder}) are the onces actually used for validation.
//===============================================================================
//== Changes:
//==    v2017.03.13A - selliott
//==        * Restructured to accomodate that the validation build specifies --folder as
//==          the root of the subtree of solution templates (and it isn't '.').
//==        * This version can handle a folder of '.' or an immediate subdirectory specified
//==          for --folder.  Note, not specifying --folder is the same as --folder=.
//===============================================================================

var grunt = require('grunt');
require('load-grunt-tasks')(grunt);

var stripJsonComments = require("strip-json-comments");

grunt.log.ok("AMP Solution Template Validation: v" + version);
grunt.log.ok("... command line args = " + process.argv.join(' '));

var branch = process.env.sourcebranch;
var folder = grunt.option('folder') || branch || '.';
grunt.log.ok("folder passed is " + folder);

var stripSubFolder = '.stripped'; // subdirectory to hold comment-stripped json files which are validated.
var folderStripped = './' + stripSubFolder;

// before and after strip locations for the UI file
// Note: this file is expected in the root of the subtree for the solution templates.  i.e., directly in $folder.
var uiBasename = "createUIDefinition.json";
var sourceUI = `${folder}/${uiBasename}`;
var targetUI = `${stripSubFolder}/${uiBasename}`;

// The input source files to be stripped and copied to ${stripSubFolder}
// Note: file paths below are written assuming pwd is the root of the Solution Template's subdirectory tree.
var solutionInitialJsonFiles = [
    `./**/*.json`, // all of the JSON files in the directory tree
    `!./**/node_modules/**/*.json` // less any of the files that are really part of grunt 
];

grunt.initConfig({

    // Clean out the stripped subdirectory before it's repopulated (later)
    clean: grunt.file.delete(`${folderStripped}`),

    // a function to call later which will load the (stripped) UI file and validate that it's at least valid JSON.
    // Note: this is set up as a function rather than a direct value because we want to delay reading the file
    // until after it's been comment stripped.
    uidef: function() {
        return grunt.file.readJSON(targetUI);
    },

    fileExists: { // every AMP solution must have a top-level mainTemplate.json template and a createUIDefinition,json
        mainTemplate: [`${folder}/mainTemplate.json`],
        UIDefinition: [sourceUI]
    },

    stripJsonComments: { // Make comment-stripped copies of each JSON file under $folder in the stripped subdirectory
        allJson: {
            options: {
                whitespace: true
            },
            expand: true,
            src: grunt.file.expand({ cwd: `${folder}` }, solutionInitialJsonFiles),
            cwd: `${folder}`,
            dest: `${folderStripped}/`
        }
    },

    jsonlint: { // validating that files contain syntactically valid JSON (no schema used)
        allJson: {
            src: [`${stripSubFolder}/**/*.json`]
        },
        options: { // set a readable message format 
            formatter: 'msbuild',
        }
    },

    "tv4": { // validation of JSON files, with schema
        options: {
            multi: true,
            banUnknownProperties: true,
            fresh: true
        },
        validateUI: { // just the UI file
            options: {
                root: 'https://schema.management.azure.com/schemas/<%= uidef().version %>/CreateUIDefinition.MultiVm.json#',
            },
            src: [targetUI]
        },
        validateARM: { // all ARM templates (excluding the UI file)
            options: {
                root: "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
            },
            src: [`${stripSubFolder}/**/*.json`, `!${targetUI}`]
        }
    }
});

//======================================================================
// Set up the specific tasks
//======================================================================

var taskList = ["fileExists", "stripJsonComments", "jsonlint", "tv4:validateUI"];

// both task tags are equivalent.  "test" left for compatability.
grunt.task.registerTask("test", taskList);
grunt.task.registerTask("default", taskList);