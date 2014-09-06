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
register = {}

Micros.set 'ms_folder', 'microservices'
Micros.set 'start_port', '4501'
Micros.spawn (service) -> eval "#{service.$name} = service"



# --- Routing Service -----------------------------------------------------------

router = new MicroService 'router'
router.$set 'api', 'ws'
router.$set 'port', 4500

runtime = (req, res, next) ->

runtime.finish = (req, res, next) ->
  console.log req, res
  if register[req.key]?
    register[req.key] res
    delete register[req.key]

router.$install runtime
router.$listen -> console.log "Started routing service on port 4500"

generate_router_key = (req) ->
  "#{req.socket.remoteAddress}:#{req.socket.remotePort}:#{(Math.floor((do Math.random) * 10**8))}"



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
        Pictures.one req.query._id, cb
      recommendations: (cb) ->
        # here be dragons - get real recommendations:
        dummy = _id: -1, url: 'img/construction.png', subtitle: 'tuc vsr mag dieses Bild'
        recommendations = _.times count_rec, ->dummy
        cb null, recommendations
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
  Flickr.find keywords:keywords, limit:9, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/pictures/hot
# trainingset: returns 9 top pictures of the last year
app.get '/pictures/hot', (req, res) ->
  Flickr.hot limit:9, (err, pictures) ->
    return res.end err.message if err
    # Flickr.cache.add pictures
    # async.eachLimit pictures, 1, Pictures.add
    return res.json pictures

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



# ------------------------------------------------------------------------------

app.get '/recommendations', (req,res) ->
  # hard data for debugging:
  Users.all (err,users) ->
    return res.end 'ERROR: no user available' unless users[0]
    return res.json users[0]

    # Start the MicroChain
    key = generate_router_key req
    # Set request paramezers
    request =
      key: key                     # dragons: move to micros.coffee
      current_user: users[0]._id   # id
      type: 'Picture'              # Picture
      count: 8                     # 8 recommednations requested
      context: req.body.context    # ????????
    # Register Callback
    register[key] = (data) -> res.json data
    setTimeout (-> reco.exec request), 0



# --- start server  ------------------------------------------------------------

server = app.listen 4343
console.log "Listening on port 4343"

