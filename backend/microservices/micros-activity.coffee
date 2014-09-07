## Libs

_ = require 'underscore'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'activity'
ms.$set 'api', 'ws'

qc = 0.01

# Dummy
activity = (req, res, next) ->
  console.log 'activity'
  next req, res

# The Activity Filter (req.activities, req.interests, req.context, req.type)
# Filters all Activities from friends with the interest profile
activity.filter = (req, res, next) ->
  req.recos = []
  interests = req.interests['dc:keyword']
  for item in req.activities
    # Filter elements throgh interests and key word clouds
    correlation = interests.reduce( (akk, interest) ->
      if _.contains item.metatags, interest.name
        # A stronger weight on postive likes ageinst negativ feedback or unknown items
        akk += (interest.like * interest.like)
      else akk
    , 0)
    req.recos.push({
      item: _.pick item, ['url', 'title', 'rating', '_id']
      prediction: correlation
    }) if correlation >= qc

  console.log req.recos
  delete req.activities
  next req, res

ms.$install activity

## Module Export

module.exports = ms
