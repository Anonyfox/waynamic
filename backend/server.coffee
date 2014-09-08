#!/usr/bin/env coffee

require 'coffee-script'
_ = require 'underscore'
async = require 'async'

express = require 'express'
app = express()

NeDB = require 'nedb'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Users = require './lib/users'
Pictures = require './lib/pictures'
Feedback = require './lib/feedback'

MediaApi = require './lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
Youtube = do MediaApi.Youtube
iTunes = do MediaApi.iTunes



# --- authentification ---------------------------------------------------------

# passport = require "passport"
# passportLocal = require("passport-local").Strategy
# NedbStore = require('connect-nedb-session')(express)
# userdb = new NeDB filename: "data/user.json", autoload: true
# userdb.ensureIndex {fieldname: "nodeId", unique: true}

# passport.use new passportLocal (nodeId, password, done) ->
#   console.log "passporting..."
#   db.getNodeById nodeId, (user) ->
#     return done(true, null) unless user
#     return done(null, user)

#   # userdb.findOne {nodeId: nodeId}, (err, user) ->
#   #   return done(err) if err
#   #   return done(null, false, {message: "Incorrect nodeId"}) unless user
#   #   return done(null, user)
# # passport.serializeUser (user, done) -> done null, user._id
# # passport.deserializeUser (id, done) -> userdb.findOne {_id: id}, (err, user) -> done(err, user)
# passport.serializeUser (user, done) -> done null, user._id
# passport.deserializeUser (id, done) -> db.getNodeById nodeId, (user) -> done(null, user)



# --- configuration ------------------------------------------------------------

app.configure ->
  app.enable 'trust proxy' # i am behind a nginx !
  app.use express.compress()
  app.use express.cookieParser()
  # app.use express.cookieSession({secret: "ThePerfectDistractionMachine", key: "nsa_tracking_cookie", cookie: {maxAge: 1000*60*60*24*365}})
  # app.use passport.initialize()
  # app.use passport.session()
  # app.set 'views', "#{__dirname}/views"
  # app.set 'view engine', 'jade'
  app.use express.json()
  app.use express.urlencoded()
  app.use express.static "#{__dirname}/../frontend/_public"
  app.use express.responseTime()

app.configure 'development', ->
  app.use app.router
  app.use express.logger()
  app.use express.errorHandler()
  app.locals.pretty = true

app.configure 'production', ->
  week = 1000 * 60 * 60 * 24 * 7
  app.use express.compress()
  app.use express.staticCache()
  app.use express.static "#{__dirname}/../frontend/_public", {maxAge: week}



# --- Setup MicroServices ------------------------------------------------------

Micros = require 'micros'
Splitter = Micros.Splitter
Chain = Micros.Chain
MicroService = Micros.MicroService
# All Services as an Array
services = []

Micros.set 'ms_folder', 'microservices'
Micros.set 'start_port', '4501'
Micros.spawn (service) ->
  eval "#{service.$name} = service"
  services.push service



# --- Routing Service -----------------------------------------------------------

router = new Micros.Router
router.$set 'port', 4500
router.$listen -> console.log "Started routing service on port 4500"



# --- Setup Chains -------------------------------------------------------------

# fdbk = 1
# inte = interests -> router.finish

# Empfehlungen basierend auf den Aktivitäten der Freunde
filter = new Splitter user.activities -> activity.filter -> normalize
fit = item.aggregate -> extend
reco = user.interests -> user.sfriends -> filter -> fit -> router.finish



# --- user routes --------------------------------------------------------------

# sanitizeUser = (obj) -> _.pick(obj, "_id", "firstName", "lastName", "createdAt", "nodeId")
# auth = (req, res, next) -> if req.isAuthenticated() then next() else res.send 401

# app.get  "/loggedin", auth, (req, res) -> res.json sanitizeUser req.user
# app.post "/login", passport.authenticate('local'), (req, res) -> res.json sanitizeUser req.user
# app.post "/logout", auth, (req, res) -> req.logout(); req.session = null; res.send 200
# app.get "/test", (req, res) -> res.json req.user

app.get '/users', (req, res) ->
  Users.all (err, result) ->
    return res.end err.message if err
    return res.json result

app.get '/users/:id', (req, res) ->
  Users.one req.params.id, (err, result) ->
    return res.end err.message if err
    return res.json result

app.get '/users/:id/profile', (req, res) ->
  async.series
    history: (cb) ->
      Users.history req.params.id, 'Picture', cb
    friends: (cb) ->
      Users.friends req.params.id, cb
    , (err, all) ->
      res.json all



# --- recommendation routes ----------------------------------------------------

# expects response of GET /user/:id/pictures += clicked:_id
app.post '/users/:id/pictures', (req, res) ->
  picIDs = _.map (_.union req.body.recommendations, req.body.trainingset), (pic) -> pic._id
  userID = parseInt req.params.id
  click = req.body.clicked
  ignores = _.filter picIDs, (_id) -> _id isnt click
  Feedback.click userID, click, (err) ->
    console.log err.message if err
    async.eachSeries ignores, (ignore, done) ->
      Feedback.ignore userID, ignore, (err) ->
        console.log err.message if err
        do done
    , ->
      return res.redirect "." unless click
      return res.redirect ".?_id=#{click}"

# http://localhost:4343/users/155040/pictures?_id=203828
app.get '/users/:id/pictures', (req, res) ->
  Users.one req.params.id, (err, user) ->
    if user._id?
      count_rec = 8
      count_ts = 4
    else
      count_rec = 0
      count_ts = 12
    async.series

      current: (cb) ->
        return cb null, {} unless req.query._id
        Pictures.one req.query._id, (err, picture) ->
          picture = picture.replace /\.jpg$/, '_o.jpg'
          cb err,

      recommendations: (cb) ->
        # dummy = _id: -1, url: 'img/construction.png', subtitle: 'tuc vsr mag dieses Bild'
        # Start the MicroChain
        if count_rec > 0
          # Register Callback
          request = router.$register req, (recommendations) ->
            recommendations = _.map recommendations, (r) ->
              {_id:r.item._id, url:r.item.url, subtitle:"#{r.friend.firstName} #{r.friend.lastName} mag dieses Bild"}
            cb null, recommendations
          # Set request paramezers
          request.user = user._id                                 # id
          request.type = 'Picture'                                # Picture
          request.count = count_rec                                # number of recommednations
          request.context = req.query._id if req.query.__dirname  # The recommendation context
          # Start the chain with event loop
          setTimeout (-> router.$exec reco, request), 0
        else cb null, []

      trainingset: (cb) ->
        Pictures.random count_ts, (err, pictures) ->
          pictures = _.map pictures, (picture) -> _id:picture._id, url:picture.url, subtitle: 'weitere Empfehlungen von Flickr'
          cb err, pictures
      , (err, all) ->
        return res.end "ERROR in server.coffee: #{err.message}" if err
        return res.json all



# --- media proxies ------------------------------------------------------------

# query:  http://localhost:4343/pictures?keywords=forest,beach
app.get '/pictures', (req, res) ->
  keywords = req.query.keywords or ''
  keywords = keywords.split ',' unless keywords instanceof Array
  opts =
    limit:req.query.limit
    keywords:keywords
  Flickr.find opts, (err, pictures) ->
    if err
      console.log "ERROR: #{err.message}"
      res.json {}
    else
      Flickr.cache.add pictures
      async.eachLimit pictures, 1, Pictures.add, ->
        return res.json pictures

# query:  http://localhost:4343/pictures/hot
# trainingset: top pictures of the last year
app.get '/pictures/hot', (req, res) ->
  if req.query.date
    matches = req.query.date.match /^(\d{4})-(\d{2})-(\d{2})$/
    date = if matches then new Date matches[1], matches[2]-1, matches[3] else undefined
  opts =
    limit: req.query.limit
    date: date
  Flickr.hot opts, (err, pictures) ->
    if err
      console.log "ERROR: #{err.message}"
      res.json {}
    else
      Flickr.cache.add pictures
      async.eachLimit pictures, 1, Pictures.add, ->
        res.json trainingset: pictures

# query:  http://localhost:4343/videos?term=coffeescript
app.get '/videos', (req, res) ->
  term = req.query.term or ''
  Youtube.find term:term, limit:9, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/movies?term=matrix
app.get '/movies', (req,res) ->
  term = req.query.term or ''
  iTunes.movie.find term:term, limit:9, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/music?term=matrix
app.get '/music', (req,res) ->
  term = req.query.term or ''
  iTunes.music.find term:term, limit:9, (err, result) ->
    return res.end err.message if err
    return res.json result

# --- start server  ------------------------------------------------------------

server = app.listen 4343
console.log "Listening on port 4343"

