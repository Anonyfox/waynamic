## Libs

_ = require 'underscore'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'activity'
ms.$set 'api', 'ws'

qc = 0.5

# Dummy
activity = (req, res, next) ->
  console.log 'activity'
  next req, res

# The Activity Filter (req.activities, req.interests, req.context, req.type)
activity.filter = (req, res, next) ->
  req.recommendations = []
  for act in req.activities
    quality = 0
    (quality = quality + req.interests[key]) for key in _.contains req.interests, key
    quality = quality / req.interests.length
    req.recommendations.push { item: act, friend: req.user, quality: quality } if quality > qc
  req.activities = req.activities.length
  next req, res

ms.$install activity

## Module Export

module.exports = ms
