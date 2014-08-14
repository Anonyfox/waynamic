#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

_ = require "underscore"
async = require 'async'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
Stopwatch = require '../lib/stopwatch'


createPictures = (limit, cb) ->
  Stopwatch.start "load media"
  Flickr.cached limit:limit, random:true, (err, pictures) ->
    Stopwatch.stop "load media"
    Stopwatch.start "save media"
    async.eachLimit pictures, 1, (picture, done) ->
      db.query """
        MERGE (pic:Picture {url:{url}})
        ON CREATE
          SET pic.title = {title}, pic.created = timestamp(), pic.new = 1
          WITH pic
          WHERE pic.new = 1
          UNWIND {tags} AS tagname
            MERGE (t:Tag {name: tagname})
            MERGE (pic)-[:tag]->(t)
          REMOVE pic.new
        """,
        url: picture.url
        title: picture.title
        tags: picture.tags
        , done
    , ->
      Stopwatch.stop "save media"
      cb arguments...


CreateMedia.run = ->
  createPictures 2000, (err, res) ->
    console.log "ERROR: #{err}" if err

# ––– when started directly as script ––– npm run db:media –––
if process.argv[1] is __filename
  do CreateMedia.run
