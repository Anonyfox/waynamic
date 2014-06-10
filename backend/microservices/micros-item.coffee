## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'item'
ms.$set 'api', 'ws'

item = (req, res, next) ->
  console.log 'item'
  next req, res

# Gather
item.aggregate = (reg, res, next) ->
  console.log 'aggregate'
  next req, res

ms.$install item

## Module Export

module.exports = ms