## Libs

_ = require 'underscore'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'item'
ms.$set 'api', 'ws'

item = (req, res, next) ->
  console.log 'item'
  next req, res

# Gather: req[]: ele.name, ele.id, ele.qc, (ele.link), req.count
# Aggregate each recommendation set to master list
item.aggregate = (req, res, next) ->
  recommendations = []
  count = req[0].count
  for recos in req
    for reco in recos
      index = _.sortedIndex recommendations, reco, 'prediciton'
      recommendations.splice index, 0, reco
      recommendations.splice(0,1) if recommendations.length > count

  #console.log req,res
  req = req[0]
  req.user = req.current_user
  delete req.recos

  next req, recommendations

ms.$install item

## Module Export

module.exports = ms