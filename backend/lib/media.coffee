Media = exports? and exports or @Media = {}

_ = require 'underscore'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Media.add_picture = (picture, done) ->
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
