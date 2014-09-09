## Libs

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'
_ = require 'underscore'
async = require 'async'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'user'
ms.$set 'api', 'ws'

user = (req, res, next) ->
  console.log "user"
  next req, res

# expects:
#   req.user
#   req.type
# returns (example):
#   interests: {
#     'dc:keywords': [
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
  """, userID:req.user, (err, result) ->
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
      metataglist = metataglist[0...50]
      interests[metatype] = metataglist
    req.interests = interests
    # console.log interests
    next req, res

# The Friends from a user: req.user as a Scatter
user.sfriends = (req, res, next) ->
  db.query """
    START User=node({userID})
    MATCH (User)-[:`foaf:knows`]->(Friends)
    RETURN DISTINCT id(Friends) AS _id, Friends.firstName AS firstName, Friends.lastName AS lastName
  """, userID:req.user, (error, friends) ->
  # example:
  # friends = [
  #   {_id: 224993, firstName:'Beverlee', lastName:"Garr"},
  #   {_id: 224999, firstName:'Penny',    lastName:"Grasha"}
  # ]
    reqres = []
    if friends.length is 0
      # Modify the chain if no aggregate is needed
      do next.chain.pop    # Pop the filter out
      do next.chain.pop    # Pop item.aggregate out
      # Only the extend service will requested
      reqres.push req
    else
      for friend in friends
        nreq = _.clone req
        nreq.current_user = nreq.user
        nreq.user = friend._id
        nreq.firstName = friend.firstName
        nreq.lastName = friend.lastName
        reqres.push nreq

    reqres.push res
    console.log friends
    next.apply @, reqres

# The Activities from a user: req.user
user.activities = (req, res, next) ->
  db.query """
    START Friend=node({friend}), Current=node({user})
    MATCH (Friend)-[like:`like`]->(Media:#{req.type})-[:`dc:keyword`]->(Metatag)<-[interest:`foaf:interest`]-(Current)
    WHERE not (Current)-[:`like`]->(Media)  // only media not yet clicked
          and interest.like > 0             // only metatags matching current's interests
          and (Current)-[:`foaf:interest`]->()<-[:`dc:keyword`]-(Media)
    RETURN id(Media) AS _id, Media.title AS title, Media.url AS url, collect(Metatag.name) AS metatags, like.rating AS rating, like.updated AS updated
    ORDER BY updated DESC
    LIMIT 100
  """, friend:req.user, user:req.current_user, (error, likes) ->
    # example:
    # likes = [
    #   { _id:238561, title:'Tranquil Misty Dawn', url:'https://farm6.staticflickr.com/5578/14180193348_00d924f364.jpg', metatags:[…], rating:1, updated:1410016227069},
    #   { _id:235797, title:'Transformación de Luz', url:'https://farm4.staticflickr.com/3845/14174050520_b662863b9c.jpg', metatags:[…], rating:1, updated:1410016225268}
    # ]

    # weight by last visit date
    count = likes.length
    max = 0
    for like, i in likes
      like.rating *= 1.0*(count-i)/count
      max = like.rating if like.rating > max
    # normalize
    for like in likes
      like.rating /= max

    req.activities = likes
    # console.log req.activities
    next req, res


ms.$install user

## Module Export

module.exports = ms
