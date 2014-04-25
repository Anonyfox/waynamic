MediaApi = exports? and exports or @MediaApi = {}

async = require 'async'
_ = require 'underscore'


# --- helper -------------------------------------------------------------------

querystring = require 'querystring'
http = require 'http'

request = (url, parameters..., cb) ->
  url += '?' + querystring.stringify _.extend parameters...
  console.log "url: ---> #{url}"
  http.get url, (res) ->
    data = ''
    res.on 'data', (chunk) -> data += chunk
    res.on 'end', ->
      try
        return cb null, JSON.parse data
      catch
        return cb new Error 'no valid json'


# --- flickr -------------------------------------------------------------------

MediaApi.Flickr = (api_key) ->
  Flickr = {}
  limit = 9

  Flickr.set = (key, value) ->
    switch key
      when 'limit' then limit = value

  Flickr.find = (keywords, cb) ->
    return unless cb
    tags = keywords.join ','
    get 'photos.search', per_page: limit, tags: tags, (err, result) ->
      return cb err if err
      pictures = []
      for photo in result.photos.photo
        crawl_one photo.id, (err, picture) ->
          return cb err if err
          pictures.push picture
          return cb null, pictures if pictures.length is limit

  crawl_one = (id, cb) ->
    async.parallel
      sizes: (cb) ->
        get 'photos.getSizes', photo_id:id, (err, result) ->
          return cb err if err
          return cb null,
            # url: result.sizes.size
            url: (_.filter result.sizes.size, (obj) -> obj.label is 'Medium')[0].source
      info: (cb) ->
        get 'photos.getInfo', photo_id:id, (err, result) ->
          return cb err if err
          return cb null,
            title: result.photo.title._content
            tags: (obj._content for obj in result.photo.tags.tag when obj._content)
      , (err, all) ->
        return cb err if err
        return cb null, _.extend(all.sizes, all.info)

  get = (method, opts, cb) ->
    url = "http://api.flickr.com/services/rest/"
    glob = method:"flickr.#{method}", api_key:api_key, format:'json', nojsoncallback:1
    request url, glob, opts, cb

  Flickr


# --- youtube ------------------------------------------------------------------

MediaApi.Youtube = ->
  youtubeSearch = require 'youtube-search'
  Youtube = {}
  limit = 9

  Youtube.set = (key, value) ->
    switch key
      when 'limit' then limit = value

  Youtube.find = (query, cb) ->
    youtubeSearch.search query, {maxResults:limit, startIndex:1}, (err, results) ->
      return cb err if err
      return cb null, (for video in results
        url: video.url
        title: video.title
        category: video.category
        author: video.author
        thumbnail: video.thumbnails[0].url
        )

  Youtube


# --- itunes -------------------------------------------------------------------

MediaApi.iTunes = ->
  iTunes = {}
  opts =
    country: 'de'
    media: 'all'
    limit: 9
    explicit: 'No'

  iTunes.set = (key, value) ->
    switch key
      when 'country' then opts.country = value
      when 'media' then opts.media = value
      when 'limit' then opts.limit = value

  # movie, podcast, music, musicVideo, audiobook, shortFilm, tvShow, software, ebook, all
  iTunes.find = (term, cb) ->
    request 'http://itunes.apple.com/search', opts, term:term, cb

  iTunes.find.movie = -> opts.media = 'movie'; iTunes.find arguments...
  iTunes.find.music = -> opts.media = 'music'; iTunes.find arguments...

  iTunes
