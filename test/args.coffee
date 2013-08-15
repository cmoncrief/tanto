assert = require 'assert'
tanto = require '../lib/tanto'

testSite = 'http://www.npmjs.org/'

describe 'Arguments', ->

  it 'should scrape from a string argument', (done) ->
    tanto testSite, (err, data) ->
      assert data.body
      done()

  it 'should scrape with an options argument', (done) ->
    tanto {url: testSite}, (err, data) ->
      assert data.body
      done()
