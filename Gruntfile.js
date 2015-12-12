var grunt = require('grunt');
require('load-grunt-tasks')(grunt);

var files = ['test/*.js'];

grunt.initConfig({
  mochacli: {
      options: {
          reporter: 'spec',
          bail: false
      },
      all: files
  },
  jshint: {
      files: files,
      options: {
          jshintrc: '.jshintrc'
      }
  },
  jscs: {
      files: {
          src: files
      },
      options: {
          config: '.jscsrc',
          esnext: true
      }
  },
  jsbeautifier: {
      test: {
          files: {
              src: files
          },
          options: {
              mode: 'VERIFY_ONLY',
              config: '.beautifyrc'
          }
      },
      write: {
          files: {
              src: files
          },
          options: {
              config: '.beautifyrc'
          }
      }
  }
});
grunt.registerTask('test', ['jshint', 'jscs', 'jsbeautifier', 'mochacli']);
