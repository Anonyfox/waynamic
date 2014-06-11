## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'normalize'
ms.$set 'api', 'ws'

# Calculate normalization: req.recommendations, rec.activities
normalize = (req, res, next) ->
  console.log 'normalize'
  next req, res

ms.$install normalize

## Module Export

module.exports = ms