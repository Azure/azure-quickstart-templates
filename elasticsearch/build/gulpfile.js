var gulp = require('gulp');
var gutil = require('gulp-util');
var yaml = require('yamljs');
var fs = require('fs');
var _ = require('lodash');
	
gulp.task('datatemplates', function() {
	var sizes = [
		2,4,8,16
	];
	
	var dataTemplate = yaml.load('../tmpl/data-nodes.yml');
	
	var dataDiskTemplate = JSON.stringify(_.find(dataTemplate.resources,
		{type: 'Microsoft.Compute/virtualMachines'}
	).properties.storageProfile.dataDisks[0]);
	
	// remove data disks
	delete _.find(dataTemplate.resources,
		{type: 'Microsoft.Compute/virtualMachines'}
	).properties.storageProfile.dataDisks;
	
	// write a zero disk template
	fs.writeFile('../data-nodes-0disk-resources.json', JSON.stringify(dataTemplate, null, '  '));
	
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
		
		fs.writeFile('../data-nodes-' + disks + 'disk-resources.json', JSON.stringify(dataTemplate, null, '  '));
	});
});
