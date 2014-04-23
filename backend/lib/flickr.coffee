Flickr = exports? and exports or @Flickr = {}

Flickr.crawl = (keywords, fn) ->
  Fl = require 'node-flickr'
  keywords or= ["sonne","meer"]
  flickr = new Fl api_key: '0969ce0028fe08ecaf0ed5537b597f1e'
  flickr.get 'photos.search', {tags: keywords.join(',')}, (result) ->
    if fn
      error = new Error 'Flickr fail!' unless flickr and result
      fn new error, result
    else
      for i in [0..5]
        flickr.get('photos.getContext', {photo_id:result[i]}, (photo) ->
          console.log photo

