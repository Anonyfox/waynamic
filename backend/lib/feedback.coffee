Feedback = exports? and exports or @Feedback = {}

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase 'http://localhost:7474'

Feedback.click = (user, mediatype, media, cb) ->
  switch mediatype
    when 'picture' then Picture user, media, +1, 'Like', cb
    when 'video'   then Video user, media, +1, 'Like', cb
    when 'movie'   then Movie user, media, +1, 'Like', cb
    when 'music'   then Music user, media, +1, 'Like', cb

Feedback.ignore = (user, mediatype, media, cb) ->
  recommendations = 9
  relevance = 0.2
  rating = relevance / recommendations
  switch mediatype
    when 'picture' then Picture user, media, rating, 'Dislike', cb
    when 'video'   then Video user, media, rating, 'Dislike', cb
    when 'movie'   then Movie user, media, rating, 'Dislike', cb
    when 'music'   then Music user, media, rating, 'Dislike', cb

Picture = (user, picture, rating, ratingtype, cb) ->
  picture.url
  picture.title
  picture.tags
  cypher = """
    MATCH (user)-[r:ratingtype]->(picture)
    SET r.rating = r.rating + rating;
    """
  db.query cypher, user:user, url:url, rating:rating, ratingtype:ratingtype cb

Video = (user, video, rating, ratingtype, cb) ->

Movie = (user, picture, rating, ratingtype, cb) ->

Music = (user, picture, rating, ratingtype, cb) ->
