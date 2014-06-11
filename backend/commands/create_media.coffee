#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

AddMedia = require '../lib/add_media'
Feedback = require '../lib/feedback'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')

createSomePictures = (limit) ->
  Flickr.cached limit:limit, (err, pictures) ->
    AddMedia.pictures pictures, (err, pictures) ->
      # return console.log "!!! ERROR: Couldn't create Media: ", err if err
      # console.log ">>> Created #{pictures.length} Users."

createSomeInterestes = ->
  # for user in users …
  Flickr.cached limit:5, random:true, (err, result) ->
    for picture of result
      Feedback.click userID, 'picture', url:picture.url, (err) -> console.log "ERROR, could not create interest"


cypher = """
  START user=node({userID})
  MATCH (user)-[:Like]->(items)
  RETURN items
  """
db.query cypher, userID:user, cb





CreateMedia.run = ->
  createSomePictures 2000
  createSomeInterests()

### when started directly as script ###
if process.argv[1] is __filename
  CreateMedia.run()
