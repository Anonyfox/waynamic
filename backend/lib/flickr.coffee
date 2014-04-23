
Flickr = exports? and exports or @Flickr = {}

# Api = require 'flickrapi'
# flickr = null

flickrOptions =
  api_key: "0969ce0028fe08ecaf0ed5537b597f1e",
  secret: "5900120da1580523"

Flickr.crawl = (fn) ->
  Fl = require 'flickrapi'
  Fl.tokenOnly flickrOptions, (error, flickr) ->
    throw new Error(error) if error
    flickr.photos.search {page: 1, per_page: 10}, (err, result) ->
      if fn 
        fn error, result
      else 
        console.log result

# Flickr.initialize = =>
#   Api.tokenOnly options, (error, token) ->
#     flickr = token
#     console.log "foo"

# Flickr.find = (keywords) ->
#   keywords or= ["sonne","meer"]
#   options =
#     text: keywords.join '+'
#     api_key: "0969ce0028fe08ecaf0ed5537b597f1e"
#   unless flickr then return new Error "not yet initialized"
#   flickr.photos.search options, (err, result) ->
#     if err then return null
#     console.log result
