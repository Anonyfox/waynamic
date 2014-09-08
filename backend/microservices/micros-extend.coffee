## Libs

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'extend'
ms.$set 'api', 'ws'

# Extends the result with additional items throught the social graph: req.interests
extend = (req, res, next) ->
  res = [] unless res instanceof Array
  # Extention
  # Fill the set with extra items throgh content based filtering or collaborative filtering
  ###if res.length < req.count
    query = """
      START User=node({userID}), Current=node(#{req.current_user})
      MATCH (User)-[like:`like`]->(Media:#{req.type})-[:`dc:keyword`]->(Metatag)
      WHERE not (Current)-[:`like`]->(Media)
      RETURN id(Media) AS _id, Media.title AS title, Media.url AS url, collect(Metatag.name) AS metatags, like.rating AS rating, like.updated AS updated
      ORDER BY updated DESC
      LIMIT 100
    """, (error, items) ->
  ###

  next req, res

ms.$install extend

## Module Export

module.exports = ms