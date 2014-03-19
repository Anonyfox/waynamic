#!/usr/bin/env coffee
Create = exports? and exports or @Create = {}

### modules/includes ###
_ = require "underscore"
async = require "async"
neo4j = require "neo4j"
db = new neo4j.GraphDatabase 'http://localhost:7474'
dict = require "./dictionary.json"
config = require "./config.json"

### functions ###
createUser = (fn) ->
  params = 
    firstName: dict.firstNames[ _.random(0,dict.firstNames.length) ] # first names: http://deron.meranda.us/data/census-derived-all-first.txt
    lastName: dict.lastNames[ _.random(0,dict.lastNames.length) ] # last names: http://www.census.gov/genealogy/www/data/1990surnames/dist.all.last
    age: _.random(16,70)
  cypher = "CREATE (u:User {params}) SET u.createdAt = timestamp()"
  db.query cypher, {params: params}, fn

createSomeUsers = (n, fn) -> async.timesSeries n, ((iterator, next) -> createUser (err, user) -> next(err, user)), fn

### actual command ###
Create.run = (userCount, userConnectivity) ->
  userCount ?= config.create.users
  userConnectivity ?= config.create.userConnectivity
  console.log "creating database..."
  createSomeUsers userCount, (err, users) -> 
    if err
      console.log "!!! ERROR: Couldn't create Users: ", err
    else
      console.log ">>> Created #{userCount} Users."
  # - add 'random' relations between user nodes
  # - create some content nodes
  # - add relations between that content nodes
  # - add relations between user nodes and content nodes

### when started directly as script ###
if process.argv[1] is __filename
  Create.run()
