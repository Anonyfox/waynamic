# Example cypher-queries to visualize the current dataset

run this commands in the [neo4j-browser](http://localhost:7474/browser/)

## System

    // Server configuration
    :GET /db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DConfiguration

    // Kernel information
    :GET /db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DKernel

    // ID Allocation
    :GET /db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DPrimitive%20count

    // Store file sizes
    :GET /db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DStore%20file%20sizes

    // Extensions
    :GET /db/data/ext

## General

    // Create a node
    CREATE (n {name:"World"}) RETURN "hello", n.name

    // Get some data
    MATCH (n) RETURN n LIMIT 100

    // What nodes are there
    MATCH (a)
    RETURN DISTINCT head(labels(a)) AS Label, count(a) AS Count

    // What is related, and how
    MATCH (a)-[r]->(b)
    WHERE labels(a) <> [] AND labels(b) <> []
    RETURN DISTINCT head(labels(a)) AS This, type(r) as To, head(labels(b)) AS That, count(r) AS Count
    LIMIT 10

    // REST API
    :GET /db/data

## graph visualization

    // 20 users likes/dislikes
    MATCH (user:User) WITH user LIMIT 20
    MATCH (user)-[r:like|dislike]->(picture:Picture)
    RETURN user, picture

    // one picture and its tags
    MATCH (p:Picture) WHERE rand()<0.01 WITH p LIMIT 1
    MATCH (p)-->(t:`dc:keyword`)
    RETURN p, t LIMIT 200

    // 3 users likes/dislikes + tags
    MATCH (user:User) WITH user LIMIT 3
    MATCH (user)-[r:like]->(picture:Picture)-->(tag:`dc:keyword`)
    RETURN user, picture, tag

    // 3 users interests in tags
    MATCH (user:User) WITH user LIMIT 3
    MATCH (user)-[r:`foaf:interest`]->(tag:`dc:keyword`)
    RETURN user, r.like AS like, r.dislike AS dislike, tag

## lists - statistics (example - just 4 fun)

    // user - ages by frequency
    MATCH (n:User)
    RETURN DISTINCT n.age AS age, count(n.age) AS amount
    ORDER BY amount DESC

    // pictures - sorted by tag-count
    MATCH (p:Picture) WITH p LIMIT 1000
    MATCH (p)-->(tag:`dc:keyword`)
    RETURN DISTINCT ID(p) AS picture, count(tag) AS tags
    ORDER BY tags DESC

## lists - statistic (relevant)

    // users - sorted by friend-count
    MATCH (u:User)
    MATCH (u)-[:`foaf:knows`]->(w)
    RETURN DISTINCT ID(u) AS user, count(w) AS friends
    ORDER BY friends DESC

    // tags having the same picture
    MATCH (p:Picture) WHERE rand()<0.1
    WITH p LIMIT 10
    MATCH (p)-->(t:`dc:keyword`)
    RETURN DISTINCT t.name AS tag, count(p) AS pictures
    ORDER BY pictures DESC

## specific nodes (id required)

// one node by id
START node=node(203567)
RETURN node

// one user and picture
START Pic = node(220255), Usr = node(203468)
MATCH (Usr)--(Tag:`dc:keyword`)--(Pic)
RETURN Pic, Usr, Tag

// interest list of one user
//START User=node(203468)
MATCH (User:User) WITH User LIMIT 1
MATCH (User)-[i:`foaf:interest`]->(metatag:`dc:keyword`)
RETURN metatag.name AS metavalue, i.like AS likes, i.dislike AS dislikes
ORDER BY likes DESC;

## manipulation

// delete stuff made by mistake
MATCH (x)
WHERE labels(x) = []
WITH x
OPTIONAL MATCH (x)-[r]-(a)
DELETE r,x

// 1. delete (dis)likes, interests
MATCH (:User)-[r:like|dislike|`foaf:interest`]->()
DELETE r

// 2. delete tags
MATCH ()-[r:`dc:keyword`]->(t:`dc:keyword`)
DELETE r,t

// 3. delete pictures
MATCH (p:Picture)
DELETE p
