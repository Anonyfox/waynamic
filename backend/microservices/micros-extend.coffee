## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'extend'
ms.$set 'api', 'ws'

# Extends the result with additional items throught the social graph: req.interests
extend = (req, res, next) ->
  if res.recommendation < req.count
    res.recommendations
    # Extend the request with globalized content
  next req, res

ms.$install extend

## Module Export

module.exports = ms