Q = require 'q'
should = require 'should'

describe 'niteo.spawn', ->

	grunt = { }

	beforeEach ->
		grunt = { }
		grunt.registerMultiTask = ->
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

	it 'should subscribe to stdout.on.', (done) ->

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

	it 'should subscribe to stderr.on', (done) ->

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

	it 'should never throw an exception.', (done) ->
		grunt.util = 
			spawn: (option, callback) =>
				throw 'Some Exception...'

		grunt.niteo.spawn { }
			.catch (err) ->
				done()

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