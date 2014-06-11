## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'user'
ms.$set 'api', 'ws'

user = (req, res, next) ->
  console.log "user"
  next req, res


# Implemented from Josua

# The Interests from a user: req.user
user.interests = (req, res, next) ->
  console.log 'interests'
  res = { test: "hello" } # test
  next req, res

# The Friends from a user: req.user as a Scatter
user.sfriends = (req, res, next) ->
  console.log 'friends'
  next req, res

# The Activities from a user: req.user
user.activities = (req, res, next) ->
  console.log 'activities'
  next req, res


ms.$install user

## Module Export

module.exports = ms