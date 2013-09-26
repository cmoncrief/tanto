assert = require 'assert'
tanto = require '../lib/tanto'

testSite = 'http://www.npmjs.org/'

describe 'Schema', ->

  it 'should return a populated value from a string', (done) ->
    schema =  title: 'title'
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert.equal data.values.title, 'npm'
      done()

  it 'should return return a populated value from an object', (done) ->
    schema = {title: {selector: 'title', type: 'text'}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert.equal data.values.title, 'npm'
      done()

  it 'should select HTML when specified', (done) ->
    schema = {home: {selector: 'li.home', type: 'html'}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert.equal data.values.home, '<a href="http://nodejs.org/">Node.js Home</a>'
      done()
    
  it 'should select text when specified', (done) ->
    schema = {home: {selector: 'li.home', type: 'text'}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert.equal data.values.home, 'Node.js Home'
      done()

  it 'should run transformations on values', (done) ->
    upperTransform = (data) -> data.toUpperCase()
    schema = {home: {selector: 'li.home', type: 'text', transform: upperTransform}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert.equal data.values.home, 'NODE.JS HOME'
      done()

  it 'should return an error hash', (done) ->
    schema = squid: 'div.li.squid', octopus: ':octopus.eleventy', title: 'title'
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values 
      assert data.errors
      assert.equal Object.keys(data.values).length, 1
      assert.equal Object.keys(data.errors).length, 2
      assert.equal data.errors.squid.message, "Value not found"
      assert.equal data.errors.octopus.message, "unmatched pseudo-class: octopus"
      done()

  it 'should allow altering the context within a transform', (done) ->
    contextTransform = (data, context) ->
      context.test = "123456"
      data
    schema = {title: {selector: 'title', type: 'text', transform: contextTransform}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert data.values.test, '123456'
      done()

  it 'should modify a passed in context', (done) ->
    context = {test: 'octopus'}
    schema = {title: {selector: 'title', type: 'text'}}
    tanto {url: testSite, schema: schema, context: context}, (err, data) ->
      assert.equal data.values.test, 'octopus'
      done()

  it 'should select the first element only', (done) ->
    schema = {test: {selector: 'li', type: 'text', eq: 0}}

    tanto {url: testSite, schema: schema}, (err, data) ->
      assert.equal data.values.test, 'Node.js Home'
      done()

  it 'should default schema types to text', (done) ->
    schema = {test: {selector: 'title'}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert.equal data.values.test, "npm"
      done()

  it 'should expand dot notation schema keys', (done) ->
    schema = {'test.nested.subnested' : {selector: 'title'}}
    tanto {url: testSite, schema: schema}, (err, data) ->
      assert.equal data.values.test.nested.subnested, "npm"
      done()





