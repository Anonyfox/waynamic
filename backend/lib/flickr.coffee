Api = require 'flickrapi'
flickr = null
auth =
  api_key: "0969ce0028fe08ecaf0ed5537b597f1e",
  secret: "5900120da1580523"

Flickr = ->

  Api.tokenOnly auth, (error, token) ->
    flickr = token
    console.log "flickr has initialized"

  Flickr.find = (keywords) ->
    options =
      text: keywords.join '+'
      api_key: "0969ce0028fe08ecaf0ed5537b597f1e"
    unless flickr then return new Error "not yet initialized"
    flickr.photos.search options, (err, result) ->
      if err then return null
      console.log result

  Flickr

module.exports = Flickr
