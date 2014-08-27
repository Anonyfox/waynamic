Users = exports? and exports or @Users = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Users.all = (cb) ->
  db.query """
    MATCH (User:User)
    RETURN
      ID(User) AS _id,
      User.firstName AS firstName,
      User.lastName AS lastName;
    """, cb

Users.one = (_id, cb) ->
  db.query userID:_id, """
    START User = node({userID})
    WHERE labels(User) = ["User"]
    RETURN
      id(User) AS _id,
      User.firstName AS firstName,
      User.lastName AS lastName;
    """, cb
