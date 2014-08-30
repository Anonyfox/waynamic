chai = require 'chai'
expect = chai.expect

describe "Flickr Picture Cache", ->
  MediaApi = require '../lib/media_api'
  Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
  ref_picture = require('../data/flickr_top.json')[0]

  it "should not add a picture that already exists", ->
    amount_before = do Flickr.cache.count
    Flickr.cache.add ref_picture
    amount_after = do Flickr.cache.count
    expect( amount_after ).to.be.equal amount_before

  it "should remove this existing picture", (done) ->
    amount_before = do Flickr.cache.count
    Flickr.cache.rm (picture) ->
      picture.url is ref_picture.url
    , ->
      amount_after = do Flickr.cache.count
      expect( amount_after ).to.be.equal (amount_before - 1)
      do done

  it "should add this picture again, which has been removes from cache", ->
    amount_before = do Flickr.cache.count
    Flickr.cache.add ref_picture
    amount_after = do Flickr.cache.count
    expect( amount_after ).to.be.equal amount_before + 1
