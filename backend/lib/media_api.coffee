MediaApi = exports? and exports or @MediaApi = {}

async = require 'async'
_ = require 'underscore'
sugar = require 'sugar'


# --- helper -------------------------------------------------------------------

querystring = require 'querystring'
http = require 'http'

request = (url, parameters..., cb) ->
  url += '?' + querystring.stringify _.extend parameters...
  console.log "url ---> #{url}"
  http.get url, (res) ->
    data = ''
    res.on 'data', (chunk) -> data += chunk
    res.on 'end', ->
      try
        return cb null, JSON.parse data
      catch
        return cb new Error 'no valid json'

http.head = (url, cb) ->
  splitted = url.match /^http:\/\/(.*?)(\/.*)/
  options =
    method: 'HEAD'
    host: splitted[1]
    path: splitted[2]
    port: 80
  do (http.request options, cb).end

yyyymmdd = ->
  date = Date()
  yyyy = date.getFullYear().toString()
  mm = (date.getMonth()+1).toString().padLeft(2, '0')
  dd = date.getDate().toString().padLeft(2, '0')
  "#{yyyy}-#{mm}#{dd}"


# --- flickr -------------------------------------------------------------------

MediaApi.Flickr = (api_key) ->
  Flickr = {}

  Flickr.cached = (limit, random, cb) ->
    pictures = require '../data/flickr_top.json'
    if random then pictures.sort -> Math.random() - 0.5
    pictures first limit

  Flickr.hot = (limit, cb) ->
    return unless cb
    limit = 1
    get 'interestingness.getList', date:'2014-06-06', per_page: limit, (err, result) ->
      gather err, result, limit, cb

  Flickr.find = (keywords, limit, cb) ->
    # Flickr.hot(1, cb); return
    return unless cb
    opts =
      per_page: 2*limit
      tags: keywords.join ','
      tag_mode: 'AND'
    get 'photos.search', opts, (err, result) ->
      gather err, result, limit, cb

  gather = (err, result, limit, cb) ->
    return cb err if err
    pictures = []
    add_one = ->
      return cb null, pictures if result.photos.photo.length is 0
      id = (do result.photos.photo.shift).id
      crawl_one id, (err, picture) ->
        return cb err if err
        if picture.url?
          pictures.push picture
          return cb null, pictures if pictures.length is limit
        else
          do add_one
    amount = Math.min limit, result.photos.photo.length
    cb new Error 'no photos returned' if amount is 0
    async.times amount, add_one

  crawl_one = (id, cb) ->
    async.parallel
      sizes: (cb) ->
        get 'photos.getSizes', photo_id:id, (err, result) ->
          return cb err if err
          url = (_.filter result.sizes.size, (obj) -> obj.label is 'Medium')[0].source
          # http.head url, (res) -> # here some freezes take place
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
    glob = method:"flickr.#{method}", api_key:api_key, format:'json', nojsoncallback:1
    request url, glob, opts, cb

  Flickr


# --- youtube ------------------------------------------------------------------

MediaApi.Youtube = ->
  youtubeSearch = require 'youtube-search'
  Youtube = {}

  Youtube.find = (query, limit, cb) ->
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
    explicit: 'No'

  iTunes.find = (term, limit, cb) ->
    request 'http://itunes.apple.com/search', opts, media:'all', term:term, limit:limit, cb

  iTunes.find.music = (term, limit, cb) ->
    request 'http://itunes.apple.com/search', opts, media:'music', term:term, limit:limit, (err, result) ->
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

  iTunes.find.movie = (term, limit, cb) ->
    request 'http://itunes.apple.com/search', opts, media:'movie', term:term, limit:limit, (err, result) ->
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
