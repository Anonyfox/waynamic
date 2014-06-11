#!/usr/bin/env coffee
CreateMedia = exports? and exports or @CreateMedia = {}

AddMedia = require '../lib/add_media'
Feedback = require '../lib/feedback'
MediaApi = require '../lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')

getUsers = (err, cb) ->
  cypher = """
    MATCH (users:User)
    RETURN users
  """
  db.query cypher, cb

createSomePictures = (limit) ->
  Flickr.cached limit:limit, (err, pictures) ->
    AddMedia.pictures pictures, (err, pictures) ->
      # return console.log "!!! ERROR: Couldn't create Media: ", err if err
      # console.log ">>> Created #{pictures.length} Users."

createSomeInterestes = () ->
  getusers (err, users) ->
    for user of Users
      Flickr.cached limit:5, random:true, (err, pictures) ->
        for picture of pictures
          Feedback.click user.id, 'picture', url:picture.url, (err) -> console.log "ERROR, could not create interest"

# npm run db:media
CreateMedia.run = ->
  createSomePictures 2000
  createSomeInterests()

### when started directly as script ###
if process.argv[1] is __filename
  CreateMedia.run()
