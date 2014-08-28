chai = require 'chai'
expect = chai.expect

describe "Flickr Picture Cache", ->
  MediaApi = require '../lib/media_api'
  Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')

  it "should not add a picture that already exists", (done) ->
    Flickr.cached limit:Infinity, (err, result) ->
      previous_amount = result.length
      Flickr.add2cache url: "http://farm6.staticflickr.com/5542/14373896613_97b0f6c67c.jpg"
      Flickr.cached limit:Infinity, (err, result) ->
        expect( result.length ).to.be.equal previous_amount
        do done
