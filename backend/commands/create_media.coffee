#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

AddMedia = require '../lib/add_media'
Feedback = require '../lib/feedback'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')

getUsers = (cb) ->
  cypher = """
    MATCH (user:User)
    RETURN user LIMIT 20
  """
  db.query cypher, cb

createSomePictures = (limit, cb) ->
  Flickr.cached limit:limit, random:true, (err, pictures) ->
    AddMedia.pictures pictures, cb

createSomeInterests = ->
  getUsers (err, users) ->
    for user in users
      Flickr.cached limit:5, random:true, (err, pictures) ->
        for picture in pictures
          Feedback.click user.user.id, 'picture', url:picture.url, (err, result) ->
            console.log result
            console.log "ERROR, could not create interest" if err

# npm run db:media
CreateMedia.run = ->
  createSomePictures 1, (err, pictures) ->
    createSomeInterests()

### when started directly as script ###
if process.argv[1] is __filename
  CreateMedia.run()
