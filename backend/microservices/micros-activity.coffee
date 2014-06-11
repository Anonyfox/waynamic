## Libs

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'activity'
ms.$set 'api', 'ws'

# Dummy
activity = (req, res, next) ->
  console.log 'activity'
  next req, res

# The Activity Filter (req.activities, req.interests, req.context, req.type)
activity.filter = (req, res, next) ->
  for act in req.activities
    console.log 'test'
  next req, res

ms.$install activity

## Module Export

module.exports = ms
