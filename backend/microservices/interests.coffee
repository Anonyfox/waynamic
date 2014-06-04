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
    property: property  # {Genre, Album, Artist, Collection, Tag, …}
    weight: 0.1         # 10 Ignores is one dislike
  cypher = "
    START user=node({userID})
    MATCH (user)-[click:Click]->(item:type)-[:property]->(thing)
    MATCH (user)-[ignore:Ignore]->(item:type)-[:property]->(thing)
    RETURN DISTINCT thing, count(click) AS likes, count(ignore)*weight AS dislikes
    ORDER BY like DESC"
  db.query cypher, (err, result) ->
    res.history = {}
    res.history[property] = result
    next req, res

# scale to 0.0...1.0  by max likes thing
normalize = (req, res, next) ->
  for property of res.history
    max = property[0].likes * 1.0
    for thing in property
      thing.likes /= max
      thing.dislikes /= max
  next req, res

# scale like+dislike down to 0.0...1.0
combine = (req, res, next) ->
  for property of res.history
    for thing in property
      thing.likes = thing.likes * thing.likes / (thing.likes + thing.dislikes)
      delete thing.dislikes
  next req, res

Interests = history -> normalize -> combine


# --- install ------------------------------------------------------------------

ms.$install Interests
ms.$config = require config.json
