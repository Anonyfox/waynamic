#!/usr/bin/env coffee

require "coffee-script"
express = require "express"
NeDB = require "nedb"
app = express()
_ = require "underscore"

MediaApi = require './lib/media_api'
Flickr = MediaApi.Flickr()

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

app.get "/pictures", (req, res) ->
  keywords = req.params.keywords ? []
  Flickr.find keywords, (err, urls) ->
    unless urls instanceof Array then return res.json null
    res.json urls

####################
### START SERVER ###
####################

server = app.listen 4343
console.log "Listening on port 4343"
