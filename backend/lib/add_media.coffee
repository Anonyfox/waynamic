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
      CREATE UNIQUE (item:Picture {url:{url}})
      SET item.title = {title}
      SET item.createdAt = timestamp()
      FOREACH (tag IN {tags} | CREATE UNIQUE (item)-[:Tag]->(:Tag {name:tag}))
      RETURN item
      """
    db.query cypher, params, cb

  async.timesSeries pictures.length, ((i, next) ->
    create pictures[i], (err, picture) -> next(err, picture)
    ), cb
