## Libs

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'
_ = require 'underscore'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'user'
ms.$set 'api', 'ws'

user = (req, res, next) ->
  console.log "user"
  next req, res

# Implemented from Josua
# expects:  req.user  (userid)
# returns: sth like below (matching metadata)
#   { Tag: [ {metavalues:'sun', likes:0.5}, ... ]
#     Genre: ... }
user.interests = (req, res, next, metatag) ->
  mediatype = 'Picture' # globalized
  db.query """
    START User=node({userID})
    MATCH (User)-[i:`foaf:interest`]->(Metatag)
    WHERE (Metatag)<--(:#{mediatype})
    RETURN labels(Metatag)[0] AS metatag, Metatag.name AS metavalue, i.like AS likes, i.dislike AS dislikes
    ORDER BY likes DESC;
  """, userID:req.user, (err, result) ->
    result = _.groupBy result, (meta) -> meta.metatag
    for metatag, metataglist of result
      max = metataglist[0].likes * 1.0
      max = 1.0 if max is 0
      for metaitem in metataglist
        delete metaitem.metatag
        # normalize by likes
        metaitem.likes /= max
        metaitem.dislikes /= max
        # relevance dislikes
        metaitem.dislikes *= 0.3
        # combine like and disklike
        metaitem.likes = metaitem.likes * metaitem.likes / (metaitem.likes + metaitem.dislikes)
        delete metaitem.dislikes
      metataglist.sort (a, b) -> if a.likes < b.likes then 1 else -1
    req.interests = result
    next req, res

# The Friends from a user: req.user as a Scatter
user.sfriends = (req, res, next) ->
  cypher = """
    START User=node({user})
    MATCH (User)-[:`foaf:knows`]->(Friends)
    RETURN id(Friends)
    """
  db.query cypher, user:req.user, (error, result) ->
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
  # dragons/querstion
  # what do you want exactly and in which form do you want it?
  # a user has the following edges:
  #   `foaf:knows` to other `User`
  #   `like`, `dislike` to media nodes, in this case `Picture`
  #   `foaf:interest` to metadata, in this case `Tag` (dc:keyword coming soon)
  cypher = """

    """
  db.query cypher, userID:req,user, (error, result) ->
    req.activities = result
    next req, res


ms.$install user

## Module Export

module.exports = ms
