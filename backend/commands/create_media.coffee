#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

async = require 'async'

Stopwatch = require '../lib/stopwatch'
Pictures = require '../lib/pictures'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')

createPictures = (limit, cb) ->
  Stopwatch.start 'load media'
  Flickr.cache limit:limit, (err, pictures) ->
    Stopwatch.stop 'load media'
    Stopwatch.start 'save media'
    async.eachLimit pictures, 1, Pictures.add, ->
      Stopwatch.stop 'save media'
      cb arguments...

CreateMedia.run = ->
  createPictures 2000, (err, res) ->
    console.log "ERROR: #{err}" if err

# ––– when started directly as script ––– npm run db:media –––
if process.argv[1] is __filename
  do CreateMedia.run
