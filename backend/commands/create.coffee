#!/usr/bin/env coffee
Create = exports? and exports or @Create = {}

# dictionary
# first names: http://deron.meranda.us/data/census-derived-all-first.txt
# last names: http://www.census.gov/genealogy/www/data/1990surnames/dist.all.last

### modules/includes ###
_ = require "underscore"
async = require "async"
neo4j = require "neo4j"
db = new neo4j.GraphDatabase 'http://localhost:7474'
dict = require "./dictionary.json"

### functions ###
createUser = (fn) ->
  params = 
    firstName: dict.firstNames[ _.random(0,dict.firstNames.length) ]
    lastName: dict.lastNames[ _.random(0,dict.lastNames.length) ]
    age: _.random(16,70)
  cypher = "CREATE (u:User {params}) SET u.created_at = timestamp()"
  db.query cypher, {params: params}, fn # @josua - how this works: https://github.com/thingdom/node-neo4j/issues/112

createSomeUsers = (n, fn) ->
  async.timesSeries n, ((iterator, next) -> 
    createUser (err, user) -> 
      next(err, user)
  ), fn

### actual command ###
Create.run = (user=20, complexity=0.5) ->
  console.log "creating database..."
  # - create some user nodes
  createSomeUsers 5, (err, users) -> console.log err, users
  # - add 'random' relations between user nodes
  # - create some content nodes
  # - add relations between that content nodes
  # - add relations between user nodes and content nodes

### when started directly as script ###
if process.argv[1] is __filename
  Create.run()
