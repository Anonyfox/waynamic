AddMedia = exports? and exports or @AddMedia = {}

# should add media to neo, if media is not yet in database
# run this by the script creat_media.coffee (npm run db:media) to init database
# run this every time, when new data from the apis has crawled (<Apiname>.hot, <Apiname>.find)

_ = require "underscore"
async = require "async"

neo4j = require "neo4j"
db = new neo4j.GraphDatabase 'http://localhost:7474'


AddMedia.pictures = (pictures, cb) ->

  create = (picture, cb) ->
    params =
      url: picture.url
      title: picture.title
      tags: picture.tags
    cypher = """
      MERGE (i:Picture {url:{url}})
      ON CREATE
        SET i.title = {title}
        SET i.created = timestamp()
        FOREACH (tag IN {tags} | MERGE (t:Tag {name:tag}) MERGE (i)-[:Tag]->(t))
      RETURN i
      """
    db.query cypher, params, cb

  async.eachSeries pictures, ((picture, next) ->
    create picture, (err, picture) -> next err, picture
    ), cb
