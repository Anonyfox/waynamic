## Libs

coffee = require 'coffee-script'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'getui'
ms.$set 'api', 'ws'

runtime = (req, res, next, params...) ->
  next req, { hallo: 'world' }

ms.$install runtime

## Module Export

module.exports = ms
