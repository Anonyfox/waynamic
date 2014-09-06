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
  ###
  res = { recommendations: [] }
  for friend in req
    for recommendation in friend.recommendations
      position = 0
      if (position = _.find res.recommendations, (rec) -> rec.item is recommendation.item)
        if recommendation.item.quality > res.recommendations[position].quality
          res.recommendations[position].quality = recommendation.item.quality
      else
        res.recommendations.push recommendation
  _.sortBy res.recommendations, (rec) -> rec.quality
  ###
  console.log req,res
  req = req[0]
  delete req.activities
  res = [{ id: 4 }, { id: 5 }]
  next req, res

ms.$install item

## Module Export

module.exports = ms