## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'normalize'
ms.$set 'api', 'ws'

# Calculate normalization: req.recommendations, req.activities
normalize = (req, res, next) ->
  penality = req.recommendations.length / req.activities
  (rec.quality = rec.quality * penality) for rec in req.recommendations
  next req, res

ms.$install normalize

## Module Export

module.exports = ms