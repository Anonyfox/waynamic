## Libs

_ = require 'underscore'
neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

## Code

MicroService = require('micros').MicroService
ms = new MicroService 'extend'
ms.$set 'api', 'ws'

# Extends the result with additional items throught the social graph: req.interests
# for now dc:keyword only
extend = (req, res, next) ->
  req.count_cb += req.count_sb - res.length
  db.query """
    START User=node({user})
    MATCH (User)-[i:`foaf:interest`]->(Metatag)<--(Mediaitem:#{req.type})
    WHERE not (User)-[:`like`]->(Mediaitem)
          and i.like > 0
    WITH DISTINCT Mediaitem, sum(i.like * i.like / ({dislike_fac}*i.dislike + i.like)) AS interests
    ORDER BY interests DESC
    RETURN DISTINCT id(Mediaitem) AS _id, Mediaitem.url AS url, 'Passend zu Ihren Interessen' AS subtitle
    LIMIT {limit}
  """, user: req.current_user, limit: req.count_cb, dislike_fac: req.dislike_fac, (err, mediaitems) ->
      sb_ids = _.map res, (item) -> item._id
      mediaitems = _.filter mediaitems, (m) -> not (m._id in sb_ids)
      res = res.concat mediaitems
      console.log res
      next req, res

ms.$install extend

## Module Export

module.exports = ms
