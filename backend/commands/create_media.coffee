#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

async = require 'async'

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

AddMedia = require '../lib/add_media'
Feedback = require '../lib/feedback'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')


createSomePictures = (limit, cb) ->
  Flickr.cached limit:limit, random:true, (err, pictures) ->
    AddMedia.pictures pictures, cb


clearInterests = (cb) ->
  cypher = "MATCH ()-[r:Like|Dislike]->() DELETE r;"
  db.query cypher, cb


forUsers = (limit, cb) ->
  cypher = "MATCH (user:User) RETURN user LIMIT {limit};"
  cypher = "MATCH (user:User) RETURN user;" if limit is Infinity
  db.query cypher, limit:limit, (err, users) ->
    for user in users
      cb err, user.user

forPictures = (limit, cb) -> # DRAGONS: make this random
  cypher = "MATCH (picture:Picture) WHERE rand()<0.1 RETURN picture LIMIT {limit};"
  cypher = "MATCH (picture:Picture) WHERE rand()<0.1 RETURN picture;" if limit is Infinity
  db.query cypher, limit:limit, (err, pictures) ->
    for picture in pictures
      cb err, picture.picture

createSomeInterests = (cb) ->
  forUsers Infinity, (err, user) ->
    forPictures 5, (err, picture) ->
      Feedback.feedback user.id, picture.id, 1+Math.floor(4*Math.random()), 'Like', cb


# npm run db:media
CreateMedia.run = ->
  async.series [
    ((cb) -> createSomePictures 2000, cb )
  , ((cb) -> clearInterests cb )
  , ((cb) -> createSomeInterests cb )
  ], (err, res) -> console.log "ERROR: #{err}" if err


### when started directly as script ###
if process.argv[1] is __filename
  CreateMedia.run()
