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
      console.log reco, req.user
      index = _.sortedIndex recommendations, reco, 'prediction'
      if index <= count
        delete reco.item.rating
        # Some Activity from diffrent friends (extreme content push)                        2
        if recommendations[index]?.item._id is reco.item._id          # preemtive index: [1,2,3,4]
          reco.prediction += recommendations[index].prediction        # recalculate prediction
          recommendations.splice index, 1                             # delete old item
          index = _.sortedIndex recommendations, reco, 'prediction'   # check new position           2
        if recommendations[index-1]?.item._id is reco.item._id        # after preemptive indey: [1,2,3,4]
          reco.prediction += recommendations[index-1].prediction      # recalculate prediction
          recommendations.splice index-1, 1                           # delete old item
          index = _.sortedIndex recommendations, reco, 'prediction' # check new position
        # Add the friend information where the reco comes from
        reco.friend =
          _id: req.user
          firstName: req.firstName
          lastName: req.lastName
        # Adjust Recommendations
        recommendations.splice index, 0, reco
        recommendations.splice(0,1) if recommendations.length > count # remove first element

  # Descending Order
  do recommendations.reverse

  console.log recommendations
  req = reqs[0]
  req.user = req.current_user
  delete req.firstName
  delete req.lastName
  delete req.recos

  next req, recommendations

ms.$install item

## Module Export

module.exports = ms