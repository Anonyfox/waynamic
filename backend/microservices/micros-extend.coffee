## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'extend'
ms.$set 'api', 'ws'

extend = (req, res, next) ->
  console.log 'interests'
  next req, res

ms.$install extend

## Module Export

module.exports = ms