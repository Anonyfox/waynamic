## Libs

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'user'
ms.$set 'api', 'ws'

normalize = (metatag) ->
  max = metatag[0].likes * 1.0
  for metavalue in metatag
    metavalue.likes /= max
    metavalue.dislikes /= max

combine = (metatag) ->
  for tagvalue in metatag
    tagvalue.likes = tagvalue.likes * tagvalue.likes / (tagvalue.likes + tagvalue.dislikes)
    delete tagvalue.dislikes

user = (req, res, next) ->
  console.log "user"
  next req, res

# Implemented from Josua
# The Interests from a user: req.user
user.interests = (req, res, next, metatag) ->
  metatag = 'dc:keyword' # Globalized
  cypher = """
    START user=node({userID})
    MATCH (user)-[l:like]->(:Item)-[:metatag]->(metavalue)
    MATCH (user)-[d:dislike]->(:Item)-[:metatag]->(metavalue)
    RETURN DISTINCT metavalue, sum(l.amount) AS likes, sum(d.amount) AS dislikes
    ORDER BY likes DESC;
    """
  db.query cypher, userID:req.user, metatag:metatag, (error, result) ->
    normalize result
    combine result
    req.interests = result
    next req, res

# The Friends from a user: req.user as a Scatter
user.sfriends = (req, res, next) ->
  cypher = """
    START user=node({userID})
    MATCH (user)-[:'foaf:knows']->(users)
    RETURN users
    """
  db.query cypher, userID:req,user, (error, result) ->
    reqres = []
    for friend in result
      nreq = _.clone req
      nreq.user = friend
      reqres.push nreq
    reqres.push res
    if result.length is 0
      next.chain.pop()    # Pop the friends out
      next.chain.pop()    # Pop the aggregate out
    next.apply @, reqres

# The Activities from a user: req.user
user.activities = (req, res, next) ->
  cypher = """

    """
  db.query cypher, userID:req,user, (error, result) ->
    req.activities = result
    next req, res


ms.$install user

## Module Export

module.exports = ms
