# Tanto
# -----
# Copyright (c) 2013 Charles Moncrief <cmoncrief@gmail.com>
#
# MIT Licensed

# Tanto is a minimalistic web scraping utility. It supports retrieving html from basic
# requests and running arbitrary queries against it using the Cheerio library. It can
# also take a hash of field names and selectors and return a hash with the data filled
# out from the target page.

# External dependencies.

request = require 'request'
cheerio = require 'cheerio'

# The Tanto class is the main entry point of the API.

class Tanto

  # Initialization
  # --------------

  constructor: (@options, @cb) ->
    @options.timeout or= 30000
    @initSchema()
    @scrape()

  # Prepare the schema hash for later processing. When a string is used as the
  # value, replace it with a hash with default values.

  initSchema: ->
    @schema = @options.schema

    for key, value of @schema
      if typeof value is "string"
        @schema[key] = selector: value, type: "text"
      else
        @schema[key].type or= "text"

  # Begin the external request and pass in the completion function as callback.

  scrape: ->
    request @options, @process

  # Handle the data returned by request. Set up the return object by loading
  # cheerio and processing the passed in schema, if it exists.

  process: (err, req, body) =>
    if err then return @cb(err)

    @data =
      $: cheerio.load body
      body: body
      values: @options.context || {}
      errors: {}

    @readValues() if @schema

    @cb null, @data

  # Map the schema keys to their values in the external document by using
  # the passed in selectors. If any individual key takes an error store it
  # in the error hash and move on.

  readValues: ->
    for key, val of @schema 
      try 
        value = @data.$(val.selector)
      catch error
        @addSchemaError key, error
        continue

      if value.length isnt 0
        @data.values[key] = @getValue value, val
      else
        @addSchemaError key, new Error "Value not found"

  # Return the trimmed and transformed value of the field

  getValue: (data, opts) ->
    value = @getValueByType(data, opts).trim()
    @transform value, opts

  # Return the correct data type based on the schema definition

  getValueByType: (data, opts) ->
    data = data.eq(opts.eq) if opts.eq?

    switch opts.type
      when 'text' then data.text()
      when 'html' then data.html()
      when 'val' then data.val()

  # Modify the selected value via transform functions passed in via the schema

  transform: (data, opts) ->
    data = opts.transform(data, @data.values) if opts.transform?
    data
    
  # Add an error to the outgoing hash

  addSchemaError: (key, error) ->
    @data.errors[key] = error

# Main entry point. Allows a string or options hash to be passed in.

module.exports = (options, cb) ->
  opts = options

  if typeof options is "string"
    opts = url: options

  new Tanto opts, cb
