MediaApi = exports? and exports or @MediaApi = {}

async = require 'async'
_ = require 'underscore'
fs = require 'fs'


# --- helper -------------------------------------------------------------------

querystring = require 'querystring'
http = require 'http'

JSON.readFileSync = (path) ->
  if path[0] isnt '/' then path = __dirname + '/' + path
  raw = fs.readFileSync path, 'utf8'
  parsed = JSON.parse raw
  parsed

JSON.writeFileSync = (path, data) ->
  if path[0] isnt '/' then path = __dirname + '/' + path
  fs.writeFileSync path, JSON.stringify(data, null, 2)+'\n'

request = (url, parameters..., cb) ->
  url += '?' + querystring.stringify _.extend parameters...
  console.log "url ---> #{url}"
  http.get url, (res) ->
    data = ''
    res.on 'data', (chunk) -> data += chunk
    res.on 'end', ->
      try
        json = JSON.parse data
      catch err
        return cb err
      cb null, json

http.head = (url, cb) ->
  splitted = url.match /^http:\/\/(.*?)(\/.*)/
  options =
    method: 'HEAD'
    host: splitted[1]
    path: splitted[2]
    port: 80
  do (http.request options, cb).end

# format date to string
yyyymmdd = (date) ->
  yyyy = date.getFullYear().toString()
  mm = (date.getMonth()+1).toString(); if mm.length is 1 then mm = '0'+mm
  dd = date.getDate().toString(); if dd.length is 1 then dd = '0'+dd
  "#{yyyy}-#{mm}-#{dd}"


# --- flickr -------------------------------------------------------------------

MediaApi.Flickr = (api_key) ->
  Flickr = {}

  # cached are hot pics from:   05.07.14 - 08.07.14
  Flickr.cache = (opts, cb) ->
    opts.limit ?= Infinity
    pictures = require '../data/flickr_top.json'
    return cb null, pictures[0...opts.limit]

  Flickr.cache.add = (new_pics) ->
    pictures = JSON.readFileSync '../data/flickr_top.json'
    new_pics = [new_pics] unless new_pics instanceof Array
    for new_pic in new_pics
      unless _.filter(pictures, (picture) -> picture.url is new_pic.url).length
        pictures.unshift _.pick new_pic, 'url', 'title', 'tags'
    JSON.writeFileSync '../data/flickr_top.json', pictures

  Flickr.cache.rm = (cb, next) ->
    pictures = JSON.readFileSync '../data/flickr_top.json'
    pictures = _.filter pictures, (picture) -> not cb picture
    JSON.writeFileSync '../data/flickr_top.json', pictures
    do next if next

  Flickr.cache.count = ->
    (JSON.readFileSync '../data/flickr_top.json').length

  # remove pictures that have insuffizient tags
  Flickr.cache.clean = ->
    min = 3
    Flickr.cache.rm (picture) -> picture.tags.length < min

  Flickr.hot = (opts, cb) ->
    opts.limit ?= 9
    opts.random ?= true
    opts.date ?= new Date()
    opts.date = new Date Date.now() - 1000*60*60*24 * parseInt(Math.random()*356) if opts.random
    get 'interestingness.getList', date:yyyymmdd(opts.date), per_page: 500, (err, result) ->
      collect err, result, opts.limit, cb

  Flickr.find = (opts, cb) ->
    opts.limit ?= 9
    opts.keywords ?= []
    tags = opts.keywords.join ','
    get 'photos.search', per_page:500, tag_mode: 'AND', tags:tags, (err, result) ->
      collect err, result, opts.limit, cb

  collect = (err, result, limit, cb) ->
    return cb err if err
    pictures = []
    add_one = ->
      return cb null, pictures if result.photos.photo.length is 0
      id = (do result.photos.photo.shift).id
      crawl_one id, (err, picture) ->
        return cb err if err
        if picture.url?
          pictures.push picture
          return cb null, pictures if pictures.length is amount
        else
          do add_one
    available = result.photos.photo.length
    amount = Math.min limit, available
    console.log "available: #{available}, limit: #{limit}"
    cb new Error 'no photos returned' if amount is 0
    async.times amount, add_one

  crawl_one = (id, cb) ->
    async.parallel
      sizes: (cb) ->
        get 'photos.getSizes', photo_id:id, (err, result) ->
          return cb err if err
          url = (_.filter result.sizes.size, (obj) -> obj.label is 'Medium')[0].source
          # http.head url, (res) -> # dragons: here some freezes take place
          #   console.log "url done"
          #   size = res.headers['content-length']
          #   return cb null, url:undefined if size < 15000
          return cb null, url: url
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
    request url, method:"flickr.#{method}", api_key:api_key, format:'json', nojsoncallback:1, opts, cb

  Flickr


# --- youtube ------------------------------------------------------------------

MediaApi.Youtube = ->
  youtubeSearch = require 'youtube-search'
  Youtube = {}

  Youtube.find = (opts, cb) ->
    return unless cb
    opts.limit ?= 9
    opts.term ?= ''
    youtubeSearch.search opts.term, {maxResults:opts.limit, startIndex:1}, (err, results) ->
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
  config =
    country: 'de'
    explicit: 'No'

  iTunes = {}
  iTunes.find = (opts, cb) ->
    return unless cb
    opts.term ?= ''
    opts.limit ?= 9
    request 'http://itunes.apple.com/search', config, media:'all', term:opts.term, limit:opts.limit, cb


  iTunes.music = {}
  iTunes.music.find = (opts, cb) ->
    return unless cb
    opts.term ?= ''
    opts.limit ?= 9
    request 'http://itunes.apple.com/search', config, media:'music', term:opts.term, limit:opts.limit, (err, result) ->
      return cb err if err
      # return cb err, result.results # full output
      return cb null, (for track in result.results
        wrapperType: track.wrapperType
        kind: track.kind
        preview: track.previewUrl
        artwork: track.artworkUrl100
        track:
          id: track.trackId
          name: track.trackName
          view: track.trackViewUrl
        artist:
          id: track.artistId
          name: track.artistName
          view: track.artistViewUrl
        collection:
          id: track.collectionId
          name: track.collectionName
          view: track.collectionViewUrl
        collection_artist:
          id: track.collectionArtistId
          name: track.collectionArtistName
        genre: track.primaryGenreName
        )

  iTunes.movie = {}
  iTunes.movie.find = (opts, cb) ->
    return unless cb
    opts.term ?= ''
    opts.limit ?= 9
    request 'http://itunes.apple.com/search', config, media:'movie', term:opts.term, limit:opts.limit, (err, result) ->
      return cb err if err
      # return cb err, result.results # full output
      return cb null, (for movie in result.results
        wrapperType: movie.wrapperType
        kind: movie.kind
        preview: movie.previewUrl
        artwork: movie.artworkUrl100
        track:
          id: movie.trackId
          name: movie.trackName
          view: movie.trackViewUrl
        artist:
          name: movie.artistName
        collection:
          id: movie.collectionId
          name: movie.collectionName
          view: movie.collectionViewUrl
        collection_artist:
          id: movie.collectionArtistId
          view: movie.collectionArtistViewUrl
        genre: movie.primaryGenreName
        contentAdvisoryRating: movie.contentAdvisoryRating
        )

  iTunes
