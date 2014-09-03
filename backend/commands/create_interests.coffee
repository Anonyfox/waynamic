#!/usr/bin/env coffee
CreateInterests = exports? and exports or @CreateInterests = {}

async = require 'async'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Users = require '../lib/users'
Pictures = require '../lib/pictures'
Feedback = require '../lib/feedback'
Stopwatch = require '../lib/stopwatch'

clearInterests = (cb) ->
  Stopwatch.start "clear interests"
  Feedback.clear ->
    Stopwatch.stop "clear interests"
    cb arguments...

createInterests = (amount) ->
  Stopwatch.start "create interests (trainingset)"
  Users.all (err, users) ->
    async.eachSeries users, (user, done) ->
      Pictures.random amount, (err, pictures) ->
        async.eachSeries pictures, (picture, done) ->
          Feedback.click user._id, picture._id, (err) ->
            console.log "ERROR: #{err}" if err
            do done
        , -> do done
    , -> Stopwatch.stop "create interests (trainingset)"

CreateInterests.run = ->
  async.series
    clear:
      clearInterests
    create:
      (done) -> createInterests 10, done
    , (err, res) -> console.log "ERROR: #{err}" if err


# ––– when started directly as script ––– npm run db:interests –––
if process.argv[1] is __filename
  do CreateInterests.run
