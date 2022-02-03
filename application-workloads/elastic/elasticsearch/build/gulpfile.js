/*
The MIT License (MIT)

Copyright (c) 2015 Microsoft Azure

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Created By: Trent Swanson (Full Scale 180 Inc)
This is a build script for the Azure Resource Manager (ARM) templates

Note: This is currently ad-hoc gulp tasks
	We are considering creating proper gulp modules for working with ARM templates
*/

var gulp = require('gulp');
var gutil = require('gulp-util');
var yaml = require('yamljs');
var fs = require('fs');
var _ = require('lodash');
	
gulp.task('build', ['datatemplates','mocks']);

// Generates the data node templates with different disk sizes from the YAML template
gulp.task('datatemplates', function() {
	var sizes = [
		2,4,8,16
	];
	
	// This is currently in YAML and an experiment in working with templates in YAML form
	var dataTemplate = yaml.load('../tmpl/data-nodes.yml');
	
	var dataDiskTemplate = JSON.stringify(_.find(dataTemplate.resources,
		{type: 'Microsoft.Compute/virtualMachines'}
	).properties.storageProfile.dataDisks[0]);
	
	// remove data disks for a 0 disk configuration
	delete _.find(dataTemplate.resources,
		{type: 'Microsoft.Compute/virtualMachines'}
	).properties.storageProfile.dataDisks;
	
	// write a zero disk template
	fs.writeFileSync('../nestedtemplates/data-nodes-0disk-resources.json', JSON.stringify(dataTemplate, null, '  '));
	
	//Create a template for each disk size defined
	_.forEach(sizes, function(disks) {
		var dataDisks = [];
		for (var diskIndex = 0; diskIndex < disks; diskIndex++)
		{
			var disk = JSON.parse(dataDiskTemplate.replace(/::index/g, (diskIndex+1).toString()));
			disk.lun = diskIndex;
			dataDisks.push(disk);
		}
		_.find(dataTemplate.resources,
			{type: 'Microsoft.Compute/virtualMachines'}
		).properties.storageProfile.dataDisks = dataDisks;
		
		fs.writeFileSync('../nestedtemplates/data-nodes-' + disks + 'disk-resources.json', JSON.stringify(dataTemplate, null, '  '));
	});
});

// Generate mock templates used when testing azuredeploy.json
gulp.task('mocks', ['datatemplates'], function() {
	
	// templates we will generate a mock for
	// maybe we can update this to scan for all files '*-resources.json'
	var templates = [
		"shared",
		"master-nodes",
		"client-nodes",
		"data-nodes-0disk",
		"data-nodes-2disk",
		"data-nodes-4disk",
		"data-nodes-8disk",
		"data-nodes-16disk",
		"jumpbox",
		"kibana",
		"empty"
	];
	
	_.forEach(templates, function(resource) {
		// create and write a mock for each of these used for testing
		var source = JSON.parse(fs.readFileSync('../nestedtemplates/' + resource + '-resources.json', 'utf8'));
		
		source.variables = {};
		source.resources = [];
		source.outputs = {};
		_.forOwn(source.parameters, function(value, key) {
			var output = {};
			output.type = value.type;
			output.value = '[parameters(\'' + key + '\')]'
			source.outputs[key] = output;
		});
		
		//update outputs with inputs
		//still working out generating the variables and discovering the types
		fs.writeFile('../test/' + resource  + '-resources.json', JSON.stringify(source, null, '  '))
	})
});
