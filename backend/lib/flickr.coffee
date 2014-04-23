Flickr = exports? and exports or @Flickr = {}

Flickr.crawl = (keywords, fn) ->
  keywords or= ["sonne","meer"]
  Fl = require 'node-flickr'
  flickr = new Fl api_key: '0969ce0028fe08ecaf0ed5537b597f1e'
  opts =
    per_page: 5
    page: 1
    tags: keywords.join ','
  flickr.get 'photos.search', opts, (result) ->
    if fn
      error = new Error 'Flickr fail!' unless flickr and result
      fn new error, result
    else
      for photo in result.photos.photo
        flickr.get 'photos.getInfo', {photo_id:photo.id}, (infos) ->
          console.log infos.photo.urls.url[0]._content

