Pictures = exports? and exports or @Pictures = {}

_ = require 'underscore'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Pictures.all = (cb) ->
  db.query """
    MATCH (Picture:Picture)-[:tag]->(Tag)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags
    LIMIT {limit};
    """, limit:1000, cb

Pictures.random = (limit, cb) ->
  db.query """
    MATCH (Picture:Picture)-[:tag]->(Tag)
    WHERE rand()<0.1
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags
    LIMIT {limit};
    """, limit:limit, cb

Pictures.one = (_id, cb) ->
  db.query """
    START Picture = node({pictureID})
    WHERE labels(Picture) = ['Picture']
    WITH Picture
    MATCH (Picture)-[:tag]->(Tag)
    RETURN
      id(Picture) AS _id,
      Picture.url AS url,
      Picture.title AS title,
      collect(Tag.name) AS tags;
  """, pictureID:parseInt(_id), (err, result) -> cb err, result[0]

Pictures.add = (picture, done) ->
  params = _.pick picture, 'url', 'title', 'tags'
  cypher = """
    MERGE (pic:Picture {url:{url}})
    ON CREATE
      SET pic.title = {title}, pic.created = timestamp(), pic.new = 1
      WITH pic
      WHERE pic.new = 1
      UNWIND {tags} AS tagname
        MERGE (t:Tag {name: tagname})
        MERGE (pic)-[:tag]->(t)
      REMOVE pic.new
  """
  db.query cypher, params, done
