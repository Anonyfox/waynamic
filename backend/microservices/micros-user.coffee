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

# expects:
#   req.current_user
#   req.type
# returns (example):
#   interests: {
#     'dc:keyword:': [
#       {name:'sun', likes:0.5},       # like interval 0..1
#       {name:'sea', likes:0.4}        # sort by likes descending
#     ]
#   }
user.interests = (req, res, next) ->
  db.query """
    START User=node({userID})
    MATCH (User)-[i:`foaf:interest`]->(Metatag)
    WHERE (Metatag)<--(:#{req.type})
    RETURN labels(Metatag)[0] AS metatype, Metatag.name AS name, i.like AS like, i.dislike AS dislikes
    ORDER BY like DESC;
  """, userID:req.current_user, (err, result) ->
    interests = _.groupBy result, (meta) -> meta.metatype
    for metatype, metataglist of interests
      max = metataglist[0].like * 1.0
      max = 1.0 if max is 0
      metataglist = _.map metataglist, (metatag) ->
        # normalize by likes
        metatag.like /= max
        metatag.dislikes /= max
        # relevance dislikes - hard coded
        metatag.dislikes *= 0.3
        # combine like and disklike
        metatag.like = metatag.like * metatag.like / (metatag.like + metatag.dislikes)
        # sanitize
        delete metatag.metatype
        delete metatag.dislikes
        metatag
      metataglist = _.filter metataglist, (metatag) -> metatag.like > 0
      metataglist = _.sortBy metataglist, (metatag) -> - metatag.like
    req.interests = interests
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
