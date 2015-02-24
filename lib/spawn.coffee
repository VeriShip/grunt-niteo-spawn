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
				child = grunt.util.spawn options, (error, result, code) ->

					if error?
						deferred.reject error
					else
						deferred.resolve result

				child.stdout.on 'data', (buf) ->
					deferred.notify String(buf)

				child.stderr.on 'data', (buf) ->
					deferred.notify String(buf)

			catch e
				deferred.reject e

			deferred.promise

	grunt.registerMultiTask 'niteoSpawn', ->

		done = @async()
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
					grunt.verbose.writeln S(notify).trimRight().s['gray']