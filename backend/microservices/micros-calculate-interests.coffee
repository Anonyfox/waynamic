neo4j = require 'neo4j'
db = new neo4j 'http://localhost:7474'

MicroService = require('micros').MicroService
ms = new MicroService 'Interests'
module.exports = ms

Interests = (req, res, next, type, metatag) ->
  params =
    userID: req.user
    type: type          # {Music, Video, Movie, Picture}
    metatag: metatag    # {Genre, Album, Artist, Collection, Tag, …}
  cypher = """
    START user=node({userID})
    MATCH (user)-[l:Like]->(item:type)-[:metatag]->(metavalue)
    MATCH (user)-[d:Dislike]->(item:type)-[:metatag]->(metavalue)
    RETURN DISTINCT metavalue, sum(l.amount) AS likes, sum(d.amount) AS dislikes
    ORDER BY likes DESC
    """
  db.query cypher, (err, result) ->
    normalize result
    combine result
    res[metatag] = result

normalize = (metatag) ->
  max = metatag[0].likes * 1.0
  for metavalue in metatag
    metavalue.likes /= max
    metavalue.dislikes /= max

combine = (metatag) ->
  for tagvalue in metatag
    tagvalue.likes = tagvalue.likes * tagvalue.likes / (tagvalue.likes + tagvalue.dislikes)
    delete tagvalue.dislikes

ms.$install Interests
ms.$config = require config.json
