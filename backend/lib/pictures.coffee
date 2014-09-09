Pictures = exports? and exports or @Pictures = {}

_ = require 'underscore'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Pictures.all = (cb) ->
  db.query """
    MATCH (Picture:Picture)-->(Tag:`dc:keyword`)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags;
    """, cb

Pictures.random = (limit, cb) ->
  db.query """
    MATCH (Picture:Picture)
    WITH Picture, rand() AS rand
    MATCH (Picture)-->(Tag:`dc:keyword`)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags,
      rand
    ORDER BY rand
    LIMIT {limit};
    """, limit:limit, (err, pictures) ->
      if err
        console.log "ERROR in pictures.coffee Pictures.random: #{err.message}"
        return cb null, {}
      delete picture.rand for picture in pictures
      return cb err, pictures

Pictures.one = (_id, cb) ->
  db.query """
    START Picture = node({pictureID})
    WHERE labels(Picture) = ['Picture']
    WITH Picture
    MATCH (Picture)-->(Tag:`dc:keyword`)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags;
  """, pictureID:parseInt(_id), (err, picture) ->
    if err
      console.log "ERROR in pictures.coffee Pictures.one: #{err.message}"
      return cb null, {}
    return cb null, picture[0]

Pictures.add = (picture, cb) ->
  params =
  db.query """
    MERGE (Picture:Picture {url:{url}})
    ON CREATE
      SET Picture.title = {title}, Picture.created = timestamp(), Picture.new = 1
      WITH Picture
      WHERE Picture.new = 1
      UNWIND {tags} AS tagname
        MERGE (Tag:`dc:keyword` {name: tagname})
        MERGE (Picture)-[:metatag]->(Tag)
      REMOVE Picture.new
  """, _.pick( picture, 'url', 'title', 'tags' ), cb

Pictures.get_id = (picture, cb) ->
  db.query """
    MATCH (Picture:Picture {url:{url}})-->(Tag:`dc:keyword`)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags;
  """, url:picture.url, cb

