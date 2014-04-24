MediaApi = exports? and exports or @MediaApi = {}


MediaApi.Flickr = ->
  Flickr = {}
  flickr = new (require 'node-flickr') api_key: '0969ce0028fe08ecaf0ed5537b597f1e'
  count = 5
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
    flickr.get 'photos.search', per_page: count, page: page, tags: query, (result) ->
      return unless cb
      return cb new Error 'Flickr fail!' unless flickr and result and result.photos
      pictures = []
      for photo in result.photos.photo
        flickr.get 'photos.getInfo', {photo_id:photo.id}, (infos) ->
          # console.log infos.photo
          url = infos.photo.urls.url[0]._content
          title = infos.photo.title._content
          tags = (obj._content for obj in infos.photo.tags.tag when obj._content)
          console.log typeof tags
          pictures.push {url:url, title:title, tags:tags}
          if pictures.length is count
            return cb null, pictures

  Flickr


MediaApi.Youtube = ->
  Youtube = {}
  youtube = 'here be dragons'
  count = 5
  page = 1

  Youtube
