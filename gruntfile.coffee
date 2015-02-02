module.exports = (grunt) ->

	grunt.initConfig
		createDirectories:
			dir: ['tasks']
		cleanUpDirectories:
			dir: ['tasks']
		coffee:
			compile:
				expand: true,
				flatten: false,
				dest: 'tasks',
				src: ['**/*.coffee', 'tests/**/*.coffee'],
				ext: '.js'
				cwd: 'lib'
			compileTests:
				expand: true,
				flatten: false,
				dest: 'tasks/tests',
				src: ['**/*.coffee', 'tests/**/*.coffee'],
				ext: '.js'
				cwd: 'tests'
		mochaTest:
			options:
				reporter: 'spec'
			src: ['tasks/tests/**/*.js']

	grunt.loadNpmTasks('grunt-mocha-test')
	grunt.loadNpmTasks('grunt-contrib-coffee')

	grunt.registerTask 'default', [ 'createDirectories', 'coffee', 'mochaTest' ]
	grunt.registerTask 'clean' , 'cleanUpDirectories'
	grunt.registerTask 'rebuild', 'clean', 'default'

	grunt.registerMultiTask 'createDirectories', ->
		for dir in this.data
			if not grunt.file.exists dir
				grunt.file.mkdir dir

	grunt.registerMultiTask 'cleanUpDirectories', ->
		for dir in this.data
			if grunt.file.exists dir
				grunt.file.recurse dir, (abspath) ->
					grunt.file.delete abspath
				grunt.file.delete dir, { force: true }
