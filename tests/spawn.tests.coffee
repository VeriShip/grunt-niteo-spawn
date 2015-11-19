Q = require 'q'
should = require 'should'
colors = require 'colors'

describe 'niteo.spawn', ->

	grunt = { }

	beforeEach ->
		grunt = { }
		grunt.registerMultiTask = ->
		grunt.verbose = { }
		grunt.verbose.writeln = ->
		require('../spawn.js')(grunt)

	it 'should return an error if options is undefined.', (done) ->

		grunt.niteo.spawn(undefined)
			.catch (err) ->
				done()

	it 'should return an error if options is null.', (done) ->

		grunt.niteo.spawn(null)
			.catch (err) ->
				done()
				
	it 'should call grunt.util.spawn passing the options object.', (done) ->

		actualOptions = null
		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: () ->
					stderr:
						on: () ->

				callback(null, { })

				return result

		expectedOptions =
			SomeOptions: 'dummy'
			SomeMoreOptions: true

		grunt.niteo.spawn expectedOptions
			.done (data) ->
				actualOptions.should.eql expectedOptions
				done()

	it 'should subscribe to stdout.on. when sensitive is undefined', (done) ->

		actualEvent = null
		actualFunction = null

		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: (e, f) ->
							actualEvent = e
							actualFunction = f
					stderr:
						on: () ->

				callback(null, { })

				return result


		grunt.niteo.spawn({ })
			.done (data) =>
				actualEvent.should.equal 'data'
				actualFunction.should.be.ok
				done()

	it 'should subscribe to stdout.on. when sensitive false', (done) ->

		actualEvent = null
		actualFunction = null

		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: (e, f) ->
							actualEvent = e
							actualFunction = f
					stderr:
						on: () ->

				callback(null, { })

				return result


		grunt.niteo.spawn({sensitive: false})
			.done (data) =>
				actualEvent.should.equal 'data'
				actualFunction.should.be.ok
				done()

	it 'should not subscribe to stdout.on. when sensitive true', (done) ->

		actualEvent = null
		actualFunction = null
		
		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: (e, f) ->
							actualEvent = e
							actualFunction = f
					stderr:
						on: () ->

				callback(null, { })

				return result


		grunt.niteo.spawn({ sensitive: true })
			.done (data) =>
				should.equal(actualEvent, null)
				should.equal(actualFunction, null)
				done()

	it 'should subscribe to stderr.on if sensitive is undefined', (done) ->

		actualEvent = null
		actualFunction = null

		grunt.util = 
			spawn: (option, callback) =>
				actualOptions = option
				result = 	
					stdout:
						on: ->
					stderr: 
						on: (e, f) ->
							actualEvent = e
							actualFunction = f

				callback(null, { })

				return result


		grunt.niteo.spawn({ })
			.done (data) =>
				actualEvent.should.equal 'data'
				actualFunction.should.be.ok
				done()
	
	it 'should subscribe to stderr.on if sensitive is false', (done) ->

		actualEvent = null
		actualFunction = null

		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: ->
					stderr:
						on: (e, f) ->
							actualEvent = e
							actualFunction = f

				callback(null, { })

				return result


		grunt.niteo.spawn({ sensitive: false })
			.done (data) =>
				actualEvent.should.equal 'data'
				actualFunction.should.be.ok
				done()
	
	it 'should not subscribe to stderr.on if sensitive is true', (done) ->

		actualEvent = null
		actualFunction = null

		grunt.util =
			spawn: (option, callback) =>
				actualOptions = option
				result =
					stdout:
						on: ->
					stderr:
						on: (e, f) ->
							actualEvent = e
							actualFunction = f

				callback(null, { })

				return result


		grunt.niteo.spawn({ sensitive: true })
			.done (data) =>
				should.equal(actualEvent, null)
				should.equal(actualFunction, null)
				done()

	it 'should never throw an exception.', (done) ->
		grunt.util = 
			spawn: (option, callback) =>
				throw 'Some Exception...'

		grunt.niteo.spawn { }
			.catch (err) ->
				done()

	it 'should write out the full command.', (done) ->
		
		writtenValue = null

		grunt.util = 
			spawn: (option, callback) =>
				actualOptions = option
				result = 	
					stdout:
						on: ->
					stderr: 
						on: ->

				callback(null, { })

				return result
		grunt.verbose = { }
		grunt.verbose.writeln = (value) ->
			writtenValue = value

		grunt.niteo.spawn(
			cmd: 'someCommand',
			args: [
				'arg1',
				'arg2'
			])
			.done ->
				writtenValue.should.equal colors.gray('Command: ') + colors.green('someCommand arg1 arg2')
				done()

	it 'stdout should output gray', (done) ->

		actualFunction = null

		grunt.util = 
			spawn: (option, callback) =>
				return {
					stdout:
						on: (e, f) =>
							actualFunction = f
					stderr: 
						on: -> 
				}

		grunt.niteo.spawn({ })
			.progress (data) =>
				data.should.equal "Some Message".gray
				done()

		actualFunction("Some Message")

	it 'stderr should output red', (done) ->

		actualFunction = null

		grunt.util = 
			spawn: (option, callback) =>
				return {
					stdout:
						on: ->
					stderr: 
						on: (e, f) =>
							actualFunction = f 
				}

		grunt.niteo.spawn({ })
			.progress (data) =>
				data.should.equal "Some Message".red
				done()

		actualFunction("Some Message")

describe 'niteoSpawn', ->

	task = null
	grunt = null
	callback = null

	beforeEach ->
		grunt = { }
		grunt.registerMultiTask = (name, f) ->
			task = f
		grunt.util = 
			spawn: ->
				Q(true)
		grunt.log = 
			writeln: ->
			ok: ->
		grunt.verbose = 
			writeln: ->
			ok: ->
		grunt.fail = 
			fatal: ->
		require('../spawn.js')(grunt)

		task.async = ->
			callback
		task.data = { }
		task.target = ""

	it 'should call niteo.spawn with passed data.', (done) ->

		actualData = null
		callback = ->
			actualData.should.eql task.data
			done()

		grunt.niteo.spawn = (options) ->
			actualData = options
			Q(true)

		task.data = 
			SomeProperty: "SomePropertyValue"
			BooleanValue: true

		task.call(task)

	it 'should call @data.success with passed data.', (done) ->

		actualData = null
		expectedData = 
			SomeProperty: "Properties YIPPEEEE"
			BooleanPhsych: ->

		grunt.niteo.spawn = ->		
			Q(expectedData)

		task.data.success = (passedData) ->
			actualData = passedData

		callback = ->
			actualData.should.eql expectedData
			done()

		task.call(task)

	it 'should call @data.failure with passed error.', (done) ->

		actualData = null
		expectedData = 
			SomeProperty: "Properties YIPPEEEE"
			BooleanPhsych: ->

		grunt.niteo.spawn = ->		
			Q.reject(expectedData)

		task.data.failure = (passedData) ->
			actualData = passedData

		callback = ->
			actualData.should.eql expectedData
			done()

		task.call(task)

	it 'should call grunt.fail.fatal when there is an error.', (done) ->

		grunt.niteo.spawn = ->		
			Q.reject({ })

		grunt.fail.fatal = ->
			done()

		task.data.failure = (passedData) ->

		callback = ->

		task.call(task)

	it 'should call @data.notify with passed msg.', (done) ->

		deferred = Q.defer()
		expectedData = 
			SomeProperty: "Properties YIPPEEEE"
			BooleanPhsych: ->

		grunt.niteo.spawn = ->		
			deferred.promise	

		task.data.notify = (passedData) ->
			passedData.should.eql expectedData
			done()

		task.call(task)

		deferred.notify(expectedData)

	it 'should call grunt.verbose.writeln when there is a message and silent is not defined.', (done) ->

		defered = Q.defer()
		grunt.niteo.spawn = ->		
			defered.promise

		grunt.verbose.writeln = ->
			done()

		task.call(task)

		defered.notify("Test")

	it 'should call grunt.verbose.writeln when there is a message and silent is defined as true.', (done) ->

		defered = Q.defer()
		grunt.niteo.spawn = ->		
			defered.promise

		grunt.verbose.writeln = ->
			done()

		task.data.silent = true

		task.call(task)

		defered.notify("Test")

	it 'should call grunt.log.writeln when there is a message and silent is defined as false.', (done) ->

		defered = Q.defer()
		grunt.niteo.spawn = ->
			defered.promise

		grunt.log.writeln = ->
			done()

		task.data.silent = false

		task.call(task)

		defered.notify("Test")
