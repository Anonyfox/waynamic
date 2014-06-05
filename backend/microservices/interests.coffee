_ = require 'underscore'
async = require 'async'
neo4j = require 'neo4j'
db = new neo4j 'http://localhost:7474'

MicroService = require('micros').MicroService
Chain = require('micros').Chain

ms = new MicroService 'Interests'
module.exports = ms


# --- functions ----------------------------------------------------------------

history = (req, res, next, type, property) ->
  params =
    userID: req.user
    type: type          # {Music, Video, Movie, Picture}
    metatag: metatag    # {Genre, Album, Artist, Collection, Tag, …}
  cypher = "
    START user=node({userID})
    MATCH (user)-[l:Like]->(item:type)-[:metatag]->(metavalue)
    MATCH (user)-[d:Dislike]->(item:type)-[:metatag]->(metavalue)
    RETURN DISTINCT metavalue, sum(l.amount) AS likes, sum(d.amount) AS dislikes
    ORDER BY likees DESC"
  db.query cypher, (err, result) ->
    res.history = {}
    res.history[metatag] = result
    next req, res

# scale to 0.0...1.0  by max likes metavalue
normalize = (req, res, next) ->
  for metatag of res.history
    max = metatag[0].likes * 1.0
    for metavalue in metatag
      metavalue.likes /= max
      metavalue.dislikes /= max
  next req, res

# scale like+dislike down to 0.0...1.0
combine = (req, res, next) ->
  for metatag of res.history
    for metavalue in metatag
      metavalue.likes = metavalue.likes * metavalue.likes / (metavalue.likes + metavalue.dislikes)
      delete metavalue.dislikes
  next req, res

Interests = history -> normalize -> combine


# --- install ------------------------------------------------------------------

ms.$install Interests
ms.$config = require config.json
