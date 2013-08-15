assert = require 'assert'
tanto = require '../lib/tanto'

testSite = 'http://www.npmjs.org/'

describe 'Selectors', ->

  it 'should allow arbitrary data selectors', (done) ->
    tanto testSite, (err, data) ->
      assert.equal data.$('title').text(), 'npm'
      assert.equal data.$('title').html(), 'npm'
      done()



