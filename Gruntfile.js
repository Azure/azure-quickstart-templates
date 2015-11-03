var grunt = require('grunt');
require('load-grunt-tasks')(grunt);

grunt.initConfig({
    mochacli: {
        options: {
            reporter: 'spec',
            bail: true
        },
        all: ['test/*.js']
    }
});
grunt.registerTask('test', ['mochacli']);
