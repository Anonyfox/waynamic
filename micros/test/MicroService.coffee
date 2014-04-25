## Libs
coffee = require 'coffee-script'
_ = require 'underscore'
async = require 'async'

## FLD

Micros = require './micro_services.lib.coffee'
MicroService = Micros.MicroService
Chain = Micros.Chain
Broadcast = Micros.Broadcast

## Code

# Define Services
add = require 'micros-add'
inc = require 'micros-inc'
print = require 'micros-print'

console.log add

# Define Chains
inner_chain = new Chain inc -> inc -> inc
chain = new Chain add(3) -> inner_chain -> add.sub(10) -> print

# Execute chain
chain.exec value: 2

# Spawm processes
do add.$spawn
do inc.$spawn
do print.$spawn

http = require 'http'
server = http.createServer (req,res) -> do res.end
server.listen 4000
