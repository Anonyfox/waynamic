Users = exports? and exports or @Users = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Users.all = (cb) ->
  db.query """
    MATCH (User:User)
    RETURN
      id(User) AS _id,
      User.firstName AS firstName,
      User.lastName AS lastName
    LIMIT {limit};
    """, limit:1000, cb

Users.one = (_id, cb) ->
  db.query """
    START User = node({userID})
    WHERE labels(User) = ['User']
    RETURN
      id(User) AS _id,
      User.firstName AS firstName,
      User.lastName AS lastName;
    """, userID:parseInt(_id), (err, result) -> cb err, result[0]
