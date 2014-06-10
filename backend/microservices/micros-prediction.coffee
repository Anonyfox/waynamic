## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'prediction'
ms.$set 'api', 'ws'

prediction = (req, res, next) ->
  console.log 'prediction'
  next req, res

ms.$install prediction

## Module Export

module.exports = ms