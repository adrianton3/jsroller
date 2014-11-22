module.exports = function(grunt) {

	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		uglify: {
			options: {
				banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %>; Copyright 2014 Adrian Toncean; released under the MIT license */\n'
			},
			build: {
				src: 'src/**/*.js',
				dest: 'build/<%= pkg.name %>.min.js'
			}
		},
		roll: {
			jsroll: {
				src: 'build/jsroller.min.js',
				dest: 'build/jsroller.roll.js'
			}
		}
	});


	grunt.loadNpmTasks('grunt-contrib-uglify');

	grunt.loadTasks('tools/grunt-tasks');

	grunt.registerTask('default', ['uglify', 'rollit']);
	grunt.registerTask('rollit', ['roll:jsroll']);
};