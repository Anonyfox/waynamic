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

  # console.log " | #{userID} | #{pictureID} | #{rating} | #{ratingtype} |"
  cypher = """
    START user=node({userID}), picture=node({pictureID})
    MERGE (user)-[r:#{ratingtype}]->(picture)
    ON CREATE SET
      r.created = timestamp(),
      r.updated = timestamp(),
      r.rating = {rating}
    ON MATCH SET
      r.updated = timestamp(),
      r.rating = r.rating + {rating};
    """
  db.query cypher, userID:userID, pictureID:pictureID, rating:rating, ratingtype:ratingtype, cb



Video = (user, video, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Movie = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Music = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"
