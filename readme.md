grunt-niteo-spawn
========
[![Build Status](https://travis-ci.org/VeriShip/grunt-niteo-spawn.svg?branch=master)](https://travis-ci.org/VeriShip/grunt-niteo-spawn.svg?branch=master)
[![Build status](https://ci.appveyor.com/api/projects/status/426hcw7dnonhkgrg?svg=true)](https://ci.appveyor.com/project/NiteoBuildBot/grunt-niteo-spawn)

A wrapper for [`grunt.util.spawn`](http://gruntjs.com/api/grunt.util#grunt.util.spawn) that is promised based.  It is worth noting that the output from the executable call is only visible if you specify the [`--verbose`](http://gruntjs.com/using-the-cli#verbose-v) flag from the command line.

Install
-------

```
npm install grunt-niteo-spawn --save-dev
```

Usage
-----

The `options` object that is sent to the underlying `grunt.util.spawn` method is the `this.data` property accessible within the [MultiTask](http://gruntjs.com/creating-tasks#multi-tasks).  So, the configuration of task follows that same structure.

```

grunt.loadNpmTask('grunt-niteo-spawn')

grunt.initConfig = {
	niteoSpawn: {
		cmd: 'echo',
		args: [
			'hello world!'
		]
	}
}

```

If you're task needs to process the data passed on resolve, revoke, or notify of the promise, then you can specify functions within the configuration.

```

grunt.loadNpmTask('grunt-niteo-spawn')

grunt.initConfig = {
	niteoSpawn: {
		cmd: 'echo',
		args: [
			'hello world!'
		],
		success: function(result) {
			console.log result	
		}
	}
}

```

The example above would print out the `hello world!` string.  If there was an error...


```

grunt.loadNpmTask('grunt-niteo-spawn')

grunt.initConfig = {
	niteoSpawn: {
		cmd: 'unknownCommand',
		args: [
			'hello world!'
		],
		failure: function(error) {
			console.log error	
		},
		notify: function(msg) {
			...
		}
	}
}

```

The `stdout` and `stderr` output from the spawned process is supressed by default.  If you supply the `--verbose` flag you will see it.  If you would like to see the output at all times, add a `silent: false` to the options for the target.  `silent` is `true` by default.

```
grunt.initConfig = {
	niteoSpawn: {
		default: {
			cmd: 'echo',
			args: [
				'hello world!'
			],
			silent: false
		}
	}
}
```

Advanced Usage
--------------

The `niteoSpawn` task is exposed as the `grunt.niteo.spawn` method on the grunt object.  You can use it freely within your specialized grunt tasks as well. 

```
grunt.loadNpmTask('grunt-niteo-spawn')

grunt.niteo.spawn({
	cmd: 'echo',
	args: [ 'hello world!' ]
}).done(function(result) {
	console.log result
})

```
