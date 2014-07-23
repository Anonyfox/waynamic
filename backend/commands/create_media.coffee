#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

_ = require "underscore"
async = require 'async'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Feedback = require '../lib/feedback'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
Stopwatch = require '../lib/stopwatch'


createSomePictures = (limit, cb) ->
  Stopwatch.start "load media"
  Flickr.cached limit:limit, random:true, (err, pictures) ->
    Stopwatch.stop "load media"

    Stopwatch.start "save media"
    async.eachSeries pictures, ((picture, cb) ->
      params =
        url: picture.url
        title: picture.title
        tags: picture.tags
      cypher = """
        MERGE (i:Picture {url:{url}})
        ON CREATE SET
          i.title = {title},
          i.created = timestamp()
          FOREACH (tag IN {tags} | MERGE (t:Tag {name:tag}) MERGE (i)-[:Tag]->(t))
        RETURN i
        """
      db.query cypher, params, cb
      ), ->
        Stopwatch.stop "save media"
        cb arguments...


clearInterests = (cb) ->
  Stopwatch.start "clear interests"
  db.query "MATCH ()-[r:Like|Dislike]->() DELETE r;", ->
    Stopwatch.stop "clear interests"
    cb arguments...


forUsers = (limit, cb, final) ->
  cypher = "MATCH (user:User) RETURN user LIMIT {limit};"
  cypher = "MATCH (user:User) RETURN user;" if limit is Infinity
  db.query cypher, limit:limit, (err, users) ->
    for user in users
      cb err, user.user
    do final if final?

forPictures = (limit, cb, final) -> # DRAGONS: make random better (remove hack)
  cypher = "MATCH (picture:Picture) WHERE rand()<0.1 RETURN picture LIMIT {limit};"
  cypher = "MATCH (picture:Picture) WHERE rand()<0.1 RETURN picture;" if limit is Infinity
  db.query cypher, limit:limit, (err, pictures) ->
    for picture in pictures
      cb err, picture.picture
    do final if final?

createSomeInterests = (cb) ->
  Stopwatch.start "create interests (trainingset)"
  forUsers Infinity, ((err, user) ->
    forPictures 5, (err, picture) ->
      value = 1+Math.floor(4*Math.random())
      Feedback.feedback user.id, picture.id, value, 'Like', cb
  ), ->
    Stopwatch.stop "create interests (trainingset)"


CreateMedia.run = ->
  async.series [
    ((cb) -> createSomePictures 20, cb )
  , ((cb) -> clearInterests cb )
  , ((cb) -> createSomeInterests cb )
  ], (err, res) -> console.log "ERROR: #{err}" if err


# ––– when started directly as script ––– npm run db:media –––
if process.argv[1] is __filename
  # console.log "argv"
  # console.log process.argv
  do CreateMedia.run
