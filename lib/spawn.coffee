Q = require 'q'
S = require 'string'
colors = require 'colors'

module.exports = (grunt)->

	if not grunt.niteo?
		grunt.niteo = { }

	grunt.niteo.spawn = (options) ->

			if not options?
				return Q.reject 'You must define options.'

			deferred = Q.defer()

			try
				grunt.verbose.writeln colors.gray("Command: ") + colors.green("#{options.cmd} #{if options.args then options.args.join(' ') else ''}")

				child = grunt.util.spawn options, (error, result, code) ->

					if error?
						deferred.reject error
					else
						deferred.resolve result

				if !options.sensitive?
					options.sensitive=false

				if !options.sensitive
					child.stdout.on 'data', (buf) ->
						deferred.notify String(buf).gray

					child.stderr.on 'data', (buf) ->
						deferred.notify String(buf).red

			catch e
				deferred.reject e

			deferred.promise

	grunt.registerMultiTask 'niteoSpawn', ->

		done = @async()
		@data.silent = if @data.silent? then @data.silent else true
		grunt.niteo.spawn(@data)
			.done (result) =>
					if @data.success?
						@data.success(result)
					grunt.log.ok "Successfully ran #{@target}"
					done()
				, (err) =>
					if @data.failure?
						@data.failure(err)
					grunt.fail.fatal "Error in #{@target}: #{err}"
					done()
				, (notify) =>
					if @data.notify?
						@data.notify(notify)
					msg = S(notify).trimRight().s
					if @data.silent then grunt.verbose.write msg else grunt.log.write msg
