neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

MicroService = require('micros').MicroService
ms = new MicroService 'interests'
ms.$set 'api', 'ws'

# metatag = {Genre, Album, Artist, Collection, Tag, …}
interests = (req, res, next, metatag) ->
  cypher = """
    START user=node({userID})
    MATCH (user)-[l:Like]->(:Item)-[:metatag]->(metavalue)
    MATCH (user)-[d:Dislike]->(:Item)-[:metatag]->(metavalue)
    RETURN DISTINCT metavalue, sum(l.amount) AS likes, sum(d.amount) AS dislikes
    ORDER BY likes DESC;
    """
  db.query cypher, userID:req.user, metatag:metatag (err, result) ->
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

ms.$install interests
module.exports = ms
