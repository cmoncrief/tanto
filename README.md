# Tantō

Tantō is a simplified web scraping tool for Node.js that utilizes the excellent [request](https://npmjs.org/package/request) and [cheerio](https://npmjs.org/package/cheerio) modules.

## Features

* Designed for speed
* Familiar jQuery selector syntax via [cheerio](https://npmjs.org/package/cheerio)
* Create schemas for complex data gathering

## Installation

Install via npm:

    $ npm install tanto

## Getting started

At it's simplest, Tantō takes a URL and returns a hash containing the body
of the response and the `$` object, which allows extracting data out of the response with all of the jQuery syntax available in the [cheerio module](https://npmjs.org/package/cheerio)
    
    var tanto = require('tanto');

    tanto("http://www.npmjs.org", function(err, data) {
     console.log(data.$('title').text()); // => 'npm'
    });

## Request options

Tantō also accepts an options hash in place of the URL string, and all [request](https://npmjs.org/package/request) options are accepted here.

    options = {
      method: 'POST',
      url: 'http://service.com/api',
      json: {
        test: 'abc123'
      }
    };

    tanto(options, function(err, data) {
      console.log(data.$('title').text()); 
    });

## Schemas

For more complex data retrieval, you can pass Tantō a schema that maps keys to selectors and returns them in the data hash as `values`.

    schema = {
      title: 'title',
      home: 'li.home'
    };

    tanto({url: "http://www.npmjs.org", schema: schema}, function(err, data) {
      console.log(data.values); // => { title: 'npm', home: 'Node.js Home' }
    });

## Transformations

Schemas support an optional transform function which will run on the data returned
from the selector.

    toCaps = function(data) {
      return data.toUpperCase();
    };

    schema = {
      title: 'title',
      home: {
        selector: 'li.home',
        transform: toCaps
      }
    };

    tanto({url: "http://www.npmjs.org", schema: schema}, function(err, data) {
      console.log(data.values.home);  // -> 'NODE.JS HOME'
    });

## API

### tanto(options, callback)

Main entry point to scrape a single page. The first argument can be either a url string or an options object.

* `url`: The url to scrape
* `method`: HTTP method to use
* `schema`: Scraping data schema. See below for details.
* `context`: If specfied with a schema, this object will be used to store the returned values rather than creating a new one.
* All other [request options](https://npmjs.org/package/request) are also supported

The callback has two arguments, the standard `error` and a `data` object that contains the following keys:

* `body`: The raw body of the response.
* `$`: The entry point for selectors.
* `values`: If a schema was passed in, this hash will contain the keys and values that were succesfully gathered.
* `errors`: If any of the schema keys took errors (or were not found), their keys and matching errors will be populated here.

### Schemas

Schemas are a simple object containing the name of the data element to be returned and an options hash that is used to gather that data. The options hash can be specified as a selector string or as the full object if more options are needed.

Schema definitions support the following options:

* `selector`: The jQuery selector for this data element. Required.
* `type`: The type of data to return from the selector. Defaults to `text`, also supports `html`, and `value`.
* `transform`: A transformation function to run on the retrieved data.
* `eq`: If the selector used matches multiple elements, reduce it to the one at the specified index. Defaults to 0.


##### Examples

    // Simple
    schema = {
      home : 'li.home',
      title : 'title'
    }

    // Full
    schema = {
      home: {selector: 'li.home', type: 'text', transform: caps},
      input: {selector: 'input.name', type: 'value', eq: 0}
    }

### Transform functions

Transformation functions take `data` and `context` as parameters and return
the new value. Use the `context` parameter to alter or create other keys in the returned values. 

The following is an example of a transform function that sets the scraped name
value to all lowercase and also saves an uppercase copy in a new key.

    formatTitle = function(data, context) {
      context.upperTitle = data.toUpperCase()
      return data.toLowerCase()
    };

    schema = {
      title: {
        selector: 'title',
        transform: formatTitle
      }
    };

    // => {title: "npm", upperTitle: "NPM"}

## Running the tests

To run the test suite:

    $ npm install
    $ npm test

Note that the tests will generate several requests to the NPM website.

## License

(The MIT License)

Copyright (c) 2013 Charles Moncrief <<cmoncrief@gmail.com>>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.