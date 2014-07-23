#!/usr/bin/env coffee
Clear = exports? and exports or @Clear = {}

neo4j = require "neo4j"
db = new neo4j.GraphDatabase 'http://localhost:7474'

### actual command ###
Clear.run = (user=20, complexity=0.5) ->
  console.log "deleting database..."
  cypher = """
    MATCH (n)
    OPTIONAL MATCH (n)-[r]-()
    DELETE r,n;
  """
  db.query cypher, {}, () ->
    console.log "database CLEAR!"

### when started directly as script ###
if process.argv[1] is __filename
  Clear.run()
