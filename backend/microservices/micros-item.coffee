## Libs

_ = require 'underscore'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'item'
ms.$set 'api', 'ws'

item = (req, res, next) ->
  console.log 'item'
  next req, res

# Gather: req[]: ele.name, ele.id, ele.qc, (ele.link), req.count_sb
# Aggregate each recommendation set to master list
item.aggregate = (reqs, ress, next) ->
  recommendations = []
  count_sb = reqs[0].count_sb
  for req in reqs
    for reco in req.recos
      # console.log reco, req.user
      index = _.sortedIndex recommendations, reco, 'prediction'
      if index <= count_sb
        delete reco.item.rating
        # Some Activity from diffrent friends (extreme content push)
        stop = false
        _.each recommendations, (r) ->
          if r.item._id is reco.item._id
            r.prediction += reco.prediction        # recalculate prediction
            stop = true
        unless stop
          # Add the friend information where the reco comes from
          reco.friend =
            _id: req.user
            firstName: req.firstName
            lastName: req.lastName
          # Adjust Recommendations
          recommendations.splice index, 0, reco
          recommendations.splice(0,1) if recommendations.length > count_sb # remove first element

  # Descending Order
  do recommendations.reverse

  # console.log recommendations
  req = reqs[0]
  req.user = req.current_user
  delete req.firstName
  delete req.lastName
  delete req.recos

  next req, recommendations

item.format = (req, res, next) ->
  res = [] unless res instanceof Array
  res = _.map res, (r) ->
    _id:r.item._id
    url:r.item.url
    subtitle:"#{r.friend.firstName} #{r.friend.lastName} mag dieses Bild"
  console.log res
  next req, res



ms.$install item

## Module Export

module.exports = ms
