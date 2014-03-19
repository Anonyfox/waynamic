#!/usr/bin/env coffee
Create = exports? and exports or @Create = {}

Create.run = ->
  console.log "creating database..."

if process.argv[1] is __filename # when started directly as script
  Create.run()
