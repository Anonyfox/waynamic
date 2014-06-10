## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'activity'
ms.$set 'api', 'ws'

activity = (req, res, next) ->
  console.log 'activity'
  next req, res

activity.filter = (req, res, next) ->
  console.log 'interests'
  next req, res

ms.$install activity

## Module Export

module.exports = ms
