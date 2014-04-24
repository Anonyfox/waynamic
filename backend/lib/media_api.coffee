MediaApi = exports? and exports or @MediaApi = {}

http = require 'http'


MediaApi.Flickr = (api_key) ->
  Flickr = {}
  count = 9
  page = 1
  query = ''

  Flickr.set = (key, value) ->
    switch key
      when 'count' then count = value

  Flickr.find = (keywords, cb) ->
    page = 1
    query = keywords.join ','
    crawl cb

  Flickr.findNext = (cb) ->
    page += 1
    crawl cb

  crawl = (cb) ->
    return unless cb
    get 'photos.search', per_page: count, page: page, tags: query, (err, result) ->
      return cb err if err
      pictures = []
      for photo in result.photos.photo
        get 'photos.getInfo', {photo_id:photo.id}, (err, infos) ->
          return cb err if err
          pictures.push(
            url: infos.photo.urls.url[0]._content
            title: infos.photo.title._content
            tags: (obj._content for obj in infos.photo.tags.tag when obj._content)
            )
          return cb null, pictures if pictures.length is count

  get = (method, opts, cb) ->
    url = "http://api.flickr.com/services/rest/"
    url += "?&method=flickr.#{method}&api_key=#{api_key}&format=json&nojsoncallback=1"
    url += "&#{k}=#{v}" for k,v of opts
    http.get url, (res) ->
      data = ''
      res.on 'data', (chunk) -> data += chunk
      res.on 'end', ->
        # data = data.replace "'", "’"
        console.log data
        cb null, JSON.parse(data)

  Flickr


MediaApi.Youtube = ->
  Youtube = {}
  youtube = 'here be dragons'
  count = 5
  page = 1

  Youtube



