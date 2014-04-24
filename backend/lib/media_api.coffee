http = require 'http'

MediaApi = exports? and exports or @MediaApi = {}


MediaApi.Flickr = ->
  Flickr = {}
  count = 9
  page = 1
  query = ''
  flickr = new (require 'node-flickr') api_key: '0969ce0028fe08ecaf0ed5537b597f1e'

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
      console.log result.photos.photo
      for photo in result.photos.photo
        get 'photos.getInfo', {photo_id:photo.id}, (err, infos) ->
          return cb err if err
          url = infos.photo.urls.url[0]._content
          title = infos.photo.title._content
          tags = (obj._content for obj in infos.photo.tags.tag when obj._content)
          console.log typeof tags
          pictures.push {url:url, title:title, tags:tags}
          if pictures.length is count
            return cb null, pictures

  get = (method, opts, cb) ->
    apikey = '0969ce0028fe08ecaf0ed5537b597f1e'
    api_url = "http://api.flickr.com/services/rest/?&method=flickr.#{method}&api_key=#{apikey}&format=json&nojsoncallback=1"
    api_url += "&#{k}=#{v}" for k,v of opts
    http.get api_url, (res) ->
      data = ''
      res.on 'data', (chunk) -> data += chunk
      res.on 'end', -> cb null, JSON.parse(data)

  Flickr


MediaApi.Youtube = ->
  Youtube = {}
  youtube = 'here be dragons'
  count = 5
  page = 1

  Youtube



