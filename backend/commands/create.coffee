#!/usr/bin/env coffee
Create = exports? and exports or @Create = {}

### modules/includes ###
_ = require "underscore"
async = require "async"
neo4j = require "neo4j"
db = new neo4j.GraphDatabase 'http://localhost:7474'
dict = require "./dictionary.json"
config = require "./config.json"

### Cache objects to speedup the implementation ###
userCache = []

### functions ###
getRandomExistingUser = (currentUser) ->
  if userCache.length > 1
    list = _.filter userCache, (u) -> u.id isnt currentUser?.id
    i = _.random(0, list.length - 1)
    return userCache[ i ]
  else
    return null

createUserNode = (fn) ->
  params =
    firstName: dict.firstNames[ _.random(0,dict.firstNames.length) ] # first names: http://deron.meranda.us/data/census-derived-all-first.txt
    lastName: dict.lastNames[ _.random(0,dict.lastNames.length) ] # last names: http://www.census.gov/genealogy/www/data/1990surnames/dist.all.last
    age: _.random(16,70)
  cypher = "CREATE (u:User {params}) SET u.createdAt = timestamp() RETURN u"
  db.query cypher, {params: params}, (error, nodes) ->
    user = nodes[0].u
    user.index "Users", "id", user.id, ->
      userCache.push user
      target = getRandomExistingUser(user)
      if target
        user.createRelationshipTo target, "foaf:knows", {}, fn
      else
        fn? null, false

createRandomEdge = (fn) ->
  u1 = getRandomExistingUser()
  u2 = getRandomExistingUser u1
  if u1 and u2
    u1.createRelationshipTo u2, "foaf:knows", {}, fn
  else
    fn? null, false

createSomeEdges = (k, fn) ->
  async.timesSeries k, ((iterator, next) ->
    createRandomEdge (err, edge) -> next(err, edge)
  ), fn

connectNeighbors = (p, fn) ->
  cypher = [
    'START a=node(*)',
    'MATCH (a) --> (b) -- (c)',
    'WHERE NOT (a) -- (c)',
    'RETURN a, c LIMIT 10' # limiting triangle connection possibilities to achieve linear runtime. Remove the limit for more accurate results
  ].join('\n');
  db.query cypher, {}, (err, pairs) ->
    async.each pairs, ((pair, callback) ->
      if Math.random() <= p
        {a, c} = pair
        a.createRelationshipTo c, "foaf:knows", {}, callback
      else
        callback null
    ), fn

createSomeUsers = (n, k, p, fn) ->
  async.timesSeries n, ((iterator, next) ->
    console.log "iteration: ", iterator, n
    createUserNode (err, user) -> createSomeEdges k, (err, edges) -> connectNeighbors p, -> next(err, user)
  ), fn

### actual command ###
Create.run = (userCount) ->
  # import parameters for the algorithm
  n = config.create.users #how many user nodes should be created?
  k = config.create.randomEdges
  p = config.create.connectivityProbability

  # ensure indexes for users and "knows"-edges
  db.createNodeIndex "Users", ->
    db.createRelationshipIndex "foaf:knows", ->
      console.log "Creating user graph with #{n} users"
      createSomeUsers n, k, p, (err, users) ->
        if err
          console.log "!!! ERROR: Couldn't create Users: ", err
        else
          console.log ">>> Created #{n} Users."

### when started directly as script ###
if process.argv[1] is __filename
  Create.run()
