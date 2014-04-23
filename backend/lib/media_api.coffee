MediaApi = exports? and exports or @MediaApi = {}

MediaApi.Flickr = ->
  Flickr = {}
  flickr = new (require 'node-flickr') api_key: '0969ce0028fe08ecaf0ed5537b597f1e'
  count = 5
  page = 1
  query = ""

  Flickr.find = (keywords, cb) ->
    page = 1
    console.log JSON.stringify keywords
    query = keywords.join ','
    crawl cb

  Flickr.findNext = (cb) ->
    page += 1
    crawl cb

  crawl = (cb) ->
    return cb null, ["url1","url2","url3"] # for now cheating
    flickr.get 'photos.search', opts, (result) ->

  Flickr



crawl = (keywords, fn) ->
  Fl = require 'node-flickr'
  flickr = new Fl api_key: '0969ce0028fe08ecaf0ed5537b597f1e'
  opts = per_page: 5, page: 1, tags: keywords.join ','


  flickr.get 'photos.search', opts, (result) ->
    # error handling
    unless flickr and result
      return fn new Error 'Flickr fail!' if fn
    # parse photo data
    for photo in result.photos.photo
      flickr.get 'photos.getInfo', {photo_id:photo.id}, (infos) ->
        url = infos.photo.urls.url[0]._content
        return fn null, url if fn
        console.log url
    return


