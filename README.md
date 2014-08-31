waynamic
========

git clone https://github.com/Anonyfox/waynamic

## angular frontend

* install
    * `npm install brunch -g` (frontend compiler)
    * `npm install bower -g` (frontend package manager)

* build (execute commands in /frontend directory)
    * `npm install` (get npm packages from package.json)
    * `bower install` (get bower packages from bower.json)
    * `brunch watch --server` (compile and watch for changes)

* view page
  [http://localhost:4343/](http://localhost:4343/) (keep shure that the backend server has been startet)

## neo4j database

* install
    * first keep shure to have installed jvm 1.7 [wiki](https://github.com/Anonyfox/waynamic/wiki/installation-instructions)
    * `brew install neo4j` (on osx via [homebrew](http://brew.sh))
      or otherwise install ist from [neo4j homepage](http://www.neo4j.org/download)
    * `neo4j install` (initial)

* start
    * `neo4j start`

* build dataset (execute these commands in /backend directory)
    * `npm run db:clear`
    * `npm run db:create` add users and set friendships
    * `npm run db:media` add some media to database
    * `npm run db:interests` initialize random interests

* explore data if you want
    * `curl -v http://localhost:7474/db/data/`
    * [http://localhost:7474/browser/](http://localhost:7474/browser/)
    * you will find some example cypher queries in the [wiki](https://github.com/Anonyfox/waynamic/wiki/cypher-queries)

## express backend

* install
    * `npm install coffee-script -g` (coffeescript)
    * `npm install nodemon -g` (node monitor, restart if files have changed)

* build (execute these commands in /backend directory)
    * `npm install` (get npm packages from package.json)

* run (execute one these commands in /backend directory)
    * `nodemon server.coffee` (restart if files have changed)
    * `coffee server.coffee` (start once)

* test (execute these commands in /backend directory)
    * `npm test` (run test once)
    * `npm run tester` (run test an watch for changes)

* explore proxy api
    * [pictures from flickr](http://localhost:4343/pictures?keywords=forest,beach)
    * [top pictures from flickr for trainigset](http://localhost:4343/pictures/hot)
    * [videos from youtube](http://localhost:4343/videos?searchstring=coffeescript)
    * [movies from itunes](http://localhost:4343/movies?searchstring=matrix)
    * [music from itunes](http://localhost:4343/music?searchstring=matrix)

* explore api used by frontend
    * [all users](http://localhost:4343/users)
    * [one user](http://localhost:4343/users/userid) (replace userid in the url by an real userid)
    * [recommendations for one user](http://localhost:4343/users/userid/pictures) (replace userid, feedback via post-redirect-get)
