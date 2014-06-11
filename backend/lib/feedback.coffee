Feedback = exports? and exports or @Feedback = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

# Feedback.click userID, 'picture', url:'flickrwhatever', (err) ->
Feedback.click = (userID, mediatype, mediaURL, cb) ->
  switch mediatype
    when 'picture' then Picture userID, mediaURL, +1, 'Like', cb
    when 'video'   then Video userID, mediaURL, +1, 'Like', cb
    when 'movie'   then Movie userID, mediaURL, +1, 'Like', cb
    when 'music'   then Music userID, mediaURL, +1, 'Like', cb

Feedback.ignore = (userID, mediatype, mediaURL, cb) ->
  recommendations = 9
  relevance = 0.2
  rating = relevance / recommendations
  switch mediatype
    when 'picture' then Picture userID, mediaURL, rating, 'Dislike', cb
    when 'video'   then Video userID, mediaURL, rating, 'Dislike', cb
    when 'movie'   then Movie userID, mediaURL, rating, 'Dislike', cb
    when 'music'   then Music userID, mediaURL, rating, 'Dislike', cb

Picture = (userID, pictureURL, rating, ratingtype, cb) ->
  cypher = """
    START user=node({userID})
    MERGE (user)-[r:{ratingtype}]->(picture {url:{pictureURL}})
    SET r.rating = r.rating + {rating};
    """
  db.query cypher, userID:userID, pictureURL:pictureURL, rating:rating, ratingtype:ratingtype, cb



Video = (user, video, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Movie = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"

Music = (user, picture, rating, ratingtype, cb) -> return cb new Error "not yet implemented"
