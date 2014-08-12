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


createPictures = (limit, cb) ->
  Stopwatch.start "load media"
  Flickr.cached limit:limit, random:true, (err, pictures) ->
    Stopwatch.stop "load media"
    Stopwatch.start "save media"
    async.eachLimit pictures, 4, (picture, done) ->
      db.query """
        MERGE (pic:Picture {url:{url}})
        ON CREATE
          SET pic.title = {title}, pic.created = timestamp()
          FOREACH (tagname IN {tags} |
            MERGE (t:Tag {name:tagname})
            MERGE (pic)-[:tag]->(t)
          )
        """,
        url: picture.url
        title: picture.title
        tags: picture.tags
        , done
    , ->
      Stopwatch.stop "save media"
      cb arguments...


clearInterests = (cb) ->
  Stopwatch.start "clear interests"
  async.parallel
    likes: (done) ->
      db.query "MATCH (:User)-[l:like|dislike]->() DELETE l", done
    interests: (done) ->
      db.query "MATCH (:User)-[i:`foaf:interest`]->(:Tag) DELETE i;", done
    , ->
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

createInterests = (amount, cb) ->
  Stopwatch.start "create interests (trainingset)"
  forUsers Infinity, ((err, user) ->
    forPictures amount, (err, picture) ->
      rating = 1+Math.floor(3*Math.random())
      Feedback.feedback user.id, picture.id, rating, 'like', cb
  ), ->
    Stopwatch.stop "create interests (trainingset)"


CreateMedia.run = ->
  async.series
    pictures: (done) ->
      createPictures 2000, done
    clear_int:
      clearInterests
    create_int: (done) ->
      createInterests 10, done
    , (err, res) -> console.log "ERROR: #{err}" if err


# ––– when started directly as script ––– npm run db:media –––
if process.argv[1] is __filename
  # console.log "argv"
  # console.log process.argv
  do CreateMedia.run
