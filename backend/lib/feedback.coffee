Feedback = exports? and exports or @Feedback = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'


Feedback.click = (userID, mediaID, cb) ->
  rating = +1
  Feedback.feedback userID, mediaID, +1, 'like', cb

Feedback.ignore = (userID, mediaID, cb) ->
  recommendations = 9
  relevance = 0.2
  rating = relevance / recommendations
  Feedback.feedback userID, mediaID, rating, 'dislike', cb

Feedback.feedback = (userID, mediaID, rating, ratingtype, cb) ->
  cypher = "START item=node({id}) RETURN labels(item) AS mediatype;"
  db.query cypher, id:mediaID, (err, mediatype) ->
    switch mediatype[0].mediatype[0]
      when 'Picture' then Picture userID, mediaID, rating, ratingtype, cb
      when 'Video'   then Video   userID, mediaID, rating, ratingtype, cb
      when 'Movie'   then Movie   userID, mediaID, rating, ratingtype, cb
      when 'Music'   then Music   userID, mediaID, rating, ratingtype, cb

Picture = (userID, pictureID, rating, ratingtype, cb) ->
  if ratingtype is "like" then cypher = """
    START User=node({userID}), Picture=node({pictureID})
    MERGE (User)-[l:like]->(Picture)
    ON CREATE SET
      l.created = timestamp(),
      l.updated = timestamp(),
      l.rating = {rating}
    ON MATCH SET
      l.updated = timestamp(),
      l.rating = l.rating + {rating}
    WITH User, Picture
    MATCH (Picture)-[:tag]->(Tag:Tag)
    MERGE (User)-[i:`foaf:interest`]->(Tag)
    ON CREATE SET
      i.created = timestamp(),
      i.updated = timestamp(),
      i.like = {rating},
      i.dislike = 0
    ON MATCH SET
      i.updated = timestamp(),
      i.like = i.like + {rating};
    """
  else if ratingtype is "dislike" then cypher = """
    START User=node({userID}), Picture=node({pictureID})
    MERGE (User)-[d:dislike]->(Picture)
    ON CREATE SET
      d.created = timestamp(),
      d.updated = timestamp(),
      d.rating = {rating}
    ON MATCH SET
      d.updated = timestamp(),
      d.rating = d.rating + {rating}
    WITH User, Picture
    MATCH (Picture)-[:tag]->(Tag:Tag)
    MERGE (User)-[i:`foaf:interest`]->(Tag)
    ON CREATE SET
      i.created = timestamp(),
      i.updated = timestamp(),
      i.like = 0,
      i.dislike = {rating}
    ON MATCH SET
      i.updated = timestamp(),
      i.dislike = i.dislike + {rating};
    """
  db.query cypher, userID:userID, pictureID:pictureID, rating:rating, cb



Video = (user, video, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Movie = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Music = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"
