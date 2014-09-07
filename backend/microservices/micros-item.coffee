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
item.aggregate = (reqs, ress, next) ->
  recommendations = []
  count = reqs[0].count
  for req in reqs
    for reco in req.recos
      index = _.sortedIndex recommendations, reco, 'prediciton'
      console.log reco, index
      if index is (count-1)
        reco.friend =
          _id: req.user
          firstName: req.firstName
          lastName: req.lastName
        recommendations.splice index, 0, reco
        recommendations.splice(0,1)

  console.log recommendations
  req = req[0]
  req.user = req.current_user
  delete req.recos

  next req, recommendations

ms.$install item

## Module Export

module.exports = ms