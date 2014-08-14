#!/usr/bin/env coffee
CreateInterests = exports? and exports or @CreateInterests = {}

_ = require "underscore"
async = require 'async'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Feedback = require '../lib/feedback'
Stopwatch = require '../lib/stopwatch'


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
      Feedback.click user.id, picture.id, cb
  ), ->
    Stopwatch.stop "create interests (trainingset)"


CreateInterests.run = ->
  async.series
    clear:
      clearInterests
    create:
      (done) -> createInterests 10, done
    , (err, res) -> console.log "ERROR: #{err}" if err


# ––– when started directly as script ––– npm run db:interests –––
if process.argv[1] is __filename
  do CreateInterests.run
