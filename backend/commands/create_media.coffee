#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

AddMedia = require '../lib/add_media'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
Youtube = MediaApi.Youtube()
iTunes = MediaApi.iTunes()

createSomePictures = (limit) ->
  Flickr.cached limit:limit, (err, pictures) ->
    AddMedia.pictures pictures, (err, pictures) ->
      # return console.log "!!! ERROR: Couldn't create Media: ", err if err
      # console.log ">>> Created #{pictures.length} Users."

createSomeInterestes = ->



CreateMedia.run = ->
  createSomePictures 2000
  createSomeInterests()

### when started directly as script ###
if process.argv[1] is __filename
  CreateMedia.run()
