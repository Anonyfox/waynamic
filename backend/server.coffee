#!/usr/bin/env coffee

require "coffee-script"
express = require "express"
NeDB = require "nedb"
app = express()
_ = require "underscore"

MediaApi = require './lib/media_api'
Flickr = MediaApi.Flickr('0969ce0028fe08ecaf0ed5537b597f1e')
# some other:
# 6276fc67deb7a243f522a28fe8469e94
# b0fc7b76902df58206b8095537fa46a6
Youtube = MediaApi.Youtube()
iTunes = MediaApi.iTunes()

########################
### AUTHENTIFICATION ###
########################

passport = require "passport"
passportLocal = require("passport-local").Strategy
NedbStore = require('connect-nedb-session')(express)
userdb = new NeDB filename: "data/user.json", autoload: true
userdb.ensureIndex {fieldname: "name", unique: true}

passport.use new passportLocal (username, password, done) ->
  userdb.findOne {name: username}, (err, user) ->
    return done(err) if err
    return done(null, false, {message: "Incorrect Username"}) unless user
    return done(null, false, {message: "Incorrect Password"}) unless user.password = password
    return done(null, user)
passport.serializeUser (user, done) -> done null, user._id
passport.deserializeUser (id, done) -> userdb.findOne {_id: id}, (err, user) -> done(err, user)

#####################
### CONFIGURATION ###
#####################

app.configure ->
  app.enable 'trust proxy' # i am behind a nginx !
  app.use express.compress()
  app.use express.cookieParser()
  app.use express.cookieSession({secret: "ThePerfectDistractionMachine", key: "nsa_tracking_cookie", cookie: {maxAge: 1000*60*60*24*365}})
  app.use passport.initialize()
  app.use passport.session()
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


#####################
### PUBLIC ROUTES ###
#####################

sanitizeUser = (obj) -> _.pick(obj, "_id", "name", "created_at")
auth = (req, res, next) -> if req.isAuthenticated() then next() else res.send 401

app.get  "/loggedin", auth, (req, res) -> res.json sanitizeUser req.user
app.post "/login", passport.authenticate('local'), (req, res) -> res.json sanitizeUser req.user
app.post "/logout", auth, (req, res) -> req.logout(); req.session = null; res.send 200
app.post "/register", (req, res) ->
  userdb.findOne {name: req.body.username}, (err, doc) ->
    if err or doc
      err or= {error: "Username already exists!"}
      res.json 500, err
    else
      userdb.insert {name: req.body.username, password: req.body.password, created_at: new Date()}, (err, doc) ->
        req.login doc, (err) ->
          res.json sanitizeUser doc
app.get "/test", (req, res) -> res.json req.user

###########################
### Setup MicroServices ###
###########################

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
  if register[req.key]?
    register[req.key] res
    delete register[req.key]

router.$install runtime
router.$listen -> console.log "Startet routing service on port 4500"

generate_router_key = (req) ->
  "{req.socket.remoteAddress}:#{req.socket.remotePort}:#{(Math.floor((do Math.random) * 10**8))}"

# --- Setup Chains -------------------------------------------------------------

fdbk = 1
inte = interests -> router.finish
reco = getui -> router.finish

# --- media api routes ---------------------------------------------------------

# query:  http://localhost:4343/pictures?keywords=forest,beach
app.get '/pictures', (req, res) ->
  keywords = req.query.keywords or 'flickr'
  keywords = keywords.split ',' unless keywords instanceof Array
  Flickr.find keywords, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/videos?searchstring=coffeescript
app.get '/videos', (req, res) ->
  searchstring = req.query.searchstring or 'youtube'
  Youtube.find searchstring, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/movies?searchstring=matrix
app.get '/movies', (req,res) ->
  searchstring = req.query.searchstring or 'itunes'
  iTunes.find.movie searchstring, (err, result) ->
    return res.end err.message if err
    return res.json result

# query:  http://localhost:4343/music?searchstring=matrix
app.get '/music', (req,res) ->
  searchstring = req.query.searchstring or 'itunes'
  iTunes.find.music searchstring, (err, result) ->
    return res.end err.message if err
    return res.json result

app.get '/recommendations', (req,res) ->
  # Start the MicroChain
  key = do generate_router_key
  console.log key
  request = {}
  request.key = key
  # Register Callback
  register[key] = (data) -> res.json data
  setTimeout (-> reco.exec request), 0

####################
### START SERVER ###
####################

server = app.listen 4343
console.log "Listening on port 4343"

