## Libs

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
  console.log 'filter'
  next req, res

ms.$install activity

## Module Export

module.exports = ms
