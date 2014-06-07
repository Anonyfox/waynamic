## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'getfs'
ms.$set 'api', 'ws'

runtime = (req, res, next, params...) ->
  console.log "StartCode goes here!"

ms.$install runtime

## Module Export

module.exports = ms