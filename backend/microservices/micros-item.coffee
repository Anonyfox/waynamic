## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'item'
ms.$set 'api', 'ws'

item = (req, res, next) ->
  console.log 'item'
  next req, res

# Gather: req[]: ele.name, ele.id, ele.qc, (ele.link), req.count
item.aggregate = (req, res, next) ->
  console.log 'aggregate'
  next req[0], res[0]

ms.$install item

## Module Export

module.exports = ms