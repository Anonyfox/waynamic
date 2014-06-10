## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'user'
ms.$set 'api', 'ws'

user = (req, res, next) ->
  console.log "user"
  next req, res

user.interests = (req, res, next) ->
  console.log 'interests'
  next req, res

user.friends = (req, res, next) ->
  console.log 'friends'
  next req, res

user.activities = (req, res, next) ->
  console.log 'activities'
  next req, res


ms.$install user

## Module Export

module.exports = ms